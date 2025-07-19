import Foundation
import OSLog

class UserManagementService: ObservableObject {
    static let shared = UserManagementService()
    
    @Published var users: [UserInfo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let logger = Logger(subsystem: "com.scriptex.userManagement", category: "UserManagementService")
    
    private init() {
        loadUsers()
    }
    
    func loadUsers() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let systemUsers = try await fetchSystemUsers()
                self.users = systemUsers
                self.isLoading = false
                self.errorMessage = nil
                logger.info("Successfully loaded \(systemUsers.count) real users from script")
            } catch {
                self.errorMessage = "Failed to load users from script: \(error.localizedDescription)"
                self.isLoading = false
                self.users = [] // No fallback to mock data
                logger.error("Failed to load users from script: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshUsers() {
        logger.info("Refreshing user data")
        loadUsers()
    }
    
    // Test function to verify script execution
    func testScriptExecution() async -> String {
        do {
            let scriptPath = "/Users/sachinkumar/Desktop/scripts/user_manager.sh"
            
            // First test: check if script exists
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: scriptPath) else {
                return "❌ Script not found at path: \(scriptPath)"
            }
            
            // Second test: check if script is executable
            guard fileManager.isExecutableFile(atPath: scriptPath) else {
                return "❌ Script is not executable: \(scriptPath)"
            }
            
            // Third test: execute script
            logger.info("Testing script execution: sudo \(scriptPath) get_details")
            let result = try await ExecutionService.executeScript(at: [
                "sudo", scriptPath, "get_details"
            ])
            
            if result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "❌ Script executed but returned empty output"
            }
            
            let cleanResult = result.replacingOccurrences(of: "\u{001B}\[[0-9;]*m", with: "", options: .regularExpression)
            return "✅ Script executed successfully:\n\n\(cleanResult.prefix(500))..."
            
        } catch {
            return "❌ Script execution failed: \(error.localizedDescription)"
        }
    }
    
    private func fetchSystemUsers() async throws -> [UserInfo] {
        let scriptPath = "/Users/sachinkumar/Desktop/scripts/user_manager.sh"
        
        logger.info("Executing script: sudo \(scriptPath) get_details")
        
        // Execute the script to get all user details
        let result = try await ExecutionService.executeScript(at: [
            "sudo", scriptPath, "get_details"
        ])
        
        logger.info("Script output received: \(result.prefix(200))...")  // Log first 200 chars
        
        if result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw NSError(domain: "UserManagementService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Script returned empty output"
            ])
        }
        
        let users = parseScriptOutput(result)
        
        if users.isEmpty {
            logger.warning("No users parsed from script output")
        }
        
        return users
    }
    
    private func parseScriptOutput(_ output: String) -> [UserInfo] {
        var users: [UserInfo] = []
        
        logger.info("Parsing script output, length: \(output.count) characters")
        
        // Clean the output of ANSI color codes first
        let cleanOutput = output.replacingOccurrences(of: "\u{001B}\[[0-9;]*m", with: "", options: .regularExpression)
        
        // Split by the user detail headers
        let userBlocks = cleanOutput.components(separatedBy: "=== User Details for: ")
        
        logger.info("Found \(userBlocks.count - 1) user blocks")
        
        for i in 1..<userBlocks.count { // Start from 1 to skip the first empty element
            let block = userBlocks[i]
            logger.info("Processing user block \(i): \(block.prefix(100))...")
            
            if let user = parseUserBlock(block) {
                users.append(user)
                logger.info("Successfully parsed user: \(user.username)")
            } else {
                logger.warning("Failed to parse user block \(i)")
            }
        }
        
        logger.info("Total users parsed: \(users.count)")
        return users
    }
    
    private func parseUserBlock(_ block: String) -> UserInfo? {
        let lines = block.components(separatedBy: .newlines)
        
        var username: String?
        var userType: UserType = .standard
        var lastPasswordChange: Date?
        var lastLogin: Date?
        var lastLogout: Date?
        var passwordHintStatus: String?
        var secureTokenStatus: SecureTokenStatus = .unknown
        
        // Extract username from the first line (format: "username ===")
        if let firstLine = lines.first {
            let trimmedFirstLine = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Handle format: "username ==="
            if trimmedFirstLine.hasSuffix(" ===") {
                username = String(trimmedFirstLine.dropLast(4)).trimmingCharacters(in: .whitespacesAndNewlines)
            } else if let spaceIndex = trimmedFirstLine.firstIndex(of: " ") {
                username = String(trimmedFirstLine[..<spaceIndex])
            } else {
                username = trimmedFirstLine
            }
            
            logger.info("Extracted username from first line: '\(username ?? "nil")'")
        }
        
        for (lineIndex, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.hasPrefix("Username:") {
                let extractedUsername = String(trimmedLine.dropFirst(9)).trimmingCharacters(in: .whitespacesAndNewlines)
                if !extractedUsername.isEmpty {
                    username = extractedUsername
                    logger.info("Username from line \(lineIndex): \(extractedUsername)")
                }
            } else if trimmedLine.hasPrefix("User Type:") {
                let typeString = String(trimmedLine.dropFirst(10)).trimmingCharacters(in: .whitespacesAndNewlines)
                userType = typeString.contains("Administrator") ? .admin : .standard
                logger.info("User type: \(typeString) -> \(userType)")
            } else if trimmedLine.hasPrefix("Last Password Change:") {
                let dateString = String(trimmedLine.dropFirst(21)).trimmingCharacters(in: .whitespacesAndNewlines)
                lastPasswordChange = parseDate(from: dateString)
                logger.info("Password change: \(dateString) -> \(lastPasswordChange?.description ?? "nil")")
            } else if trimmedLine.hasPrefix("Last Login:") {
                let dateString = String(trimmedLine.dropFirst(12)).trimmingCharacters(in: .whitespacesAndNewlines)
                lastLogin = parseDate(from: dateString)
                logger.info("Last login: \(dateString) -> \(lastLogin?.description ?? "nil")")
            } else if trimmedLine.hasPrefix("Last Logout:") {
                let dateString = String(trimmedLine.dropFirst(13)).trimmingCharacters(in: .whitespacesAndNewlines)
                lastLogout = parseDate(from: dateString)
                logger.info("Last logout: \(dateString) -> \(lastLogout?.description ?? "nil")")
            } else if trimmedLine.hasPrefix("Password Hint Status:") {
                passwordHintStatus = String(trimmedLine.dropFirst(21)).trimmingCharacters(in: .whitespacesAndNewlines)
                logger.info("Password hint status: \(passwordHintStatus ?? "nil")")
            } else if trimmedLine.hasPrefix("Secure Token Status:") {
                let statusString = String(trimmedLine.dropFirst(20)).trimmingCharacters(in: .whitespacesAndNewlines)
                secureTokenStatus = statusString.contains("Enabled") ? .enabled : .disabled
                logger.info("Secure token: \(statusString) -> \(secureTokenStatus)")
            }
        }
        
        guard let validUsername = username, !validUsername.isEmpty else {
            logger.error("No valid username found in block")
            return nil
        }
        
        // Clean username if it has extra characters
        let cleanUsername = validUsername.components(separatedBy: .whitespacesAndNewlines).first ?? validUsername
        
        let userInfo = UserInfo(
            username: cleanUsername,
            fullName: cleanUsername, // Script doesn't provide full name, use username
            userType: userType,
            secureTokenStatus: secureTokenStatus,
            lastLoginTime: lastLogin,
            lastLogoutTime: lastLogout,
            lastPasswordChangeTime: lastPasswordChange,
            lastTerminalSessionTime: nil, // Not provided by script
            lastPasswordHintChange: passwordHintStatus == "Set" ? Date() : nil,
            email: nil,
            isActive: true, // Assume active if listed
            createdAt: Date() // Default creation date
        )
        
        logger.info("Created UserInfo for: \(cleanUsername) (\(userType))")
        return userInfo
    }
    
    private func parseDate(from dateString: String) -> Date? {
        if dateString == "Never" || dateString == "Unknown" || dateString.isEmpty {
            return nil
        }
        
        // Try multiple date formatters
        let formatters = [
            createFormatter("EEE MMM dd HH:mm:ss yyyy"),
            createFormatter("EEE MMM dd HH:mm yyyy"),
            createFormatter("MMM dd HH:mm"),
            createFormatter("yyyy-MM-dd HH:mm:ss"),
            createFormatter("MM/dd/yyyy HH:mm:ss")
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    private func createFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
}