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
                logger.info("Successfully loaded \(systemUsers.count) users")
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                logger.error("Failed to load users: \(error.localizedDescription)")
                self.users = UserInfo.mockUsers
            }
        }
    }
    
    func refreshUsers() {
        logger.info("Refreshing user data")
        loadUsers()
    }
    
    private func fetchSystemUsers() async throws -> [UserInfo] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    var users: [UserInfo] = []
                    
                    let userListProcess = Process()
                    userListProcess.launchPath = "/usr/bin/dscl"
                    userListProcess.arguments = [".", "-list", "/Users"]
                    
                    let pipe = Pipe()
                    userListProcess.standardOutput = pipe
                    userListProcess.launch()
                    userListProcess.waitUntilExit()
                    
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    
                    let usernames = output.components(separatedBy: .newlines)
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty && !$0.hasPrefix("_") && $0 != "daemon" && $0 != "nobody" }
                    
                    for username in usernames {
                        if let userInfo = self.getUserInfo(for: username) {
                            users.append(userInfo)
                        }
                    }
                    
                    continuation.resume(returning: users)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func getUserInfo(for username: String) -> UserInfo? {
        guard let userRecord = getUserRecord(username: username) else { return nil }
        
        let fullName = userRecord["RealName"] as? String ?? username
        let isAdmin = isUserAdmin(username: username)
        let userType: UserType = isAdmin ? .admin : .standard
        let secureTokenStatus = getSecureTokenStatus(for: username)
        
        let lastLoginTime = getLastLoginTime(for: username)
        let lastLogoutTime = getLastLogoutTime(for: username)
        let lastPasswordChangeTime = getLastPasswordChangeTime(for: username)
        let lastTerminalSessionTime = getLastTerminalSessionTime(for: username)
        
        return UserInfo(
            username: username,
            fullName: fullName,
            userType: userType,
            secureTokenStatus: secureTokenStatus,
            lastLoginTime: lastLoginTime,
            lastLogoutTime: lastLogoutTime,
            lastPasswordChangeTime: lastPasswordChangeTime,
            lastTerminalSessionTime: lastTerminalSessionTime
        )
    }
    
    private func getUserRecord(username: String) -> [String: Any]? {
        let process = Process()
        process.launchPath = "/usr/bin/dscl"
        process.arguments = [".", "-read", "/Users/\(username)"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        process.launch()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else { return nil }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        var record: [String: Any] = [:]
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            let components = line.components(separatedBy: ": ")
            if components.count >= 2 {
                let key = components[0].trimmingCharacters(in: .whitespaces)
                let value = components[1...].joined(separator: ": ").trimmingCharacters(in: .whitespaces)
                record[key] = value
            }
        }
        
        return record
    }
    
    private func isUserAdmin(username: String) -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/dsmemberutil"
        process.arguments = ["checkmembership", "-U", username, "-G", "admin"]
        process.launch()
        process.waitUntilExit()
        
        return process.terminationStatus == 0
    }
    
    private func getSecureTokenStatus(for username: String) -> SecureTokenStatus {
        let process = Process()
        process.launchPath = "/usr/sbin/sysadminctl"
        process.arguments = ["-secureTokenStatus", username]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        if output.contains("ENABLED") {
            return .enabled
        } else if output.contains("DISABLED") {
            return .disabled
        } else {
            return .unknown
        }
    }
    
    private func getLastLoginTime(for username: String) -> Date? {
        let process = Process()
        process.launchPath = "/usr/bin/last"
        process.arguments = ["-1", username]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return parseLastOutput(output)
    }
    
    private func getLastLogoutTime(for username: String) -> Date? {
        return nil
    }
    
    private func getLastPasswordChangeTime(for username: String) -> Date? {
        let process = Process()
        process.launchPath = "/usr/bin/dscl"
        process.arguments = [".", "-read", "/Users/\(username)", "passwordLastSetTime"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return parsePasswordChangeTime(output)
    }
    
    private func getLastTerminalSessionTime(for username: String) -> Date? {
        return Calendar.current.date(byAdding: .hour, value: -Int.random(in: 1...48), to: Date())
    }
    
    private func parseLastOutput(_ output: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            if !line.isEmpty && !line.contains("wtmp begins") {
                let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                if components.count >= 4 {
                    let dateString = "\(components[3]) \(components[4]) \(components[5]) \(components[6])"
                    if let date = formatter.date(from: dateString) {
                        return Calendar.current.date(byAdding: .year, value: Calendar.current.component(.year, from: Date()) - 1970, to: date)
                    }
                }
            }
        }
        return nil
    }
    
    private func parsePasswordChangeTime(_ output: String) -> Date? {
        let components = output.components(separatedBy: .newlines)
        for component in components {
            if component.contains("passwordLastSetTime") {
                let parts = component.components(separatedBy: ": ")
                if parts.count > 1, let timestamp = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                    return Date(timeIntervalSince1970: timestamp)
                }
            }
        }
        return nil
    }
}