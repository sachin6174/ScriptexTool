import SwiftUI
import Foundation
import Cocoa

// MARK: - UserManager Service
class UserManager: ObservableObject {
    @Published var users: [UserInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadUsers()
    }
    
    // MARK: - Load Users
    func loadUsers() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedUsers = try await getUserDetails()
                await MainActor.run {
                    self.users = loadedUsers
                    self.isLoading = false
                    Logger.shared.info("Loaded \(loadedUsers.count) users", category: "UserManager")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load users: \(error.localizedDescription)"
                    self.isLoading = false
                    Logger.shared.error("Failed to load users: \(error.localizedDescription)", category: "UserManager")
                }
            }
        }
    }
    
    private func getUserDetails() async throws -> [UserInfo] {
        let result = try await ExecutionService.executeScript(at: ["/Users/sachinkumar/Desktop/scripts/list_user_details.sh"])
        return parseUserDetails(from: result)
    }
    
    private func parseUserDetails(from output: String) -> [UserInfo] {
        var users: [UserInfo] = []
        let lines = output.components(separatedBy: .newlines)
        var currentUser: [String: String] = [:]
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("USERNAME: ") {
                // Save previous user if exists
                if !currentUser.isEmpty {
                    if let user = createUserFromParsedData(currentUser) {
                        users.append(user)
                    }
                }
                // Start new user
                currentUser = [:]
                currentUser["username"] = String(trimmedLine.dropFirst("USERNAME: ".count))
            } else if trimmedLine.hasPrefix("USER TYPE: ") {
                currentUser["userType"] = String(trimmedLine.dropFirst("USER TYPE: ".count))
            } else if trimmedLine.hasPrefix("LAST PASSWORD CHANGE: ") {
                currentUser["lastPasswordChange"] = String(trimmedLine.dropFirst("LAST PASSWORD CHANGE: ".count))
            } else if trimmedLine.hasPrefix("LAST LOGIN: ") {
                currentUser["lastLogin"] = String(trimmedLine.dropFirst("LAST LOGIN: ".count))
            } else if trimmedLine.hasPrefix("LAST LOGOUT: ") {
                currentUser["lastLogout"] = String(trimmedLine.dropFirst("LAST LOGOUT: ".count))
            } else if trimmedLine.hasPrefix("LAST PASSWORD HINT CHANGE: ") {
                currentUser["passwordHintStatus"] = String(trimmedLine.dropFirst("LAST PASSWORD HINT CHANGE: ".count))
            } else if trimmedLine.hasPrefix("SECURE TOKEN STATUS: ") {
                currentUser["secureTokenStatus"] = String(trimmedLine.dropFirst("SECURE TOKEN STATUS: ".count))
            } else if trimmedLine.hasPrefix("USER CREATION DATE: ") {
                currentUser["userCreationDate"] = String(trimmedLine.dropFirst("USER CREATION DATE: ".count))
            }
        }
        
        // Don't forget the last user
        if !currentUser.isEmpty {
            if let user = createUserFromParsedData(currentUser) {
                users.append(user)
            }
        }
        
        return users
    }
    
    private func createUserFromParsedData(_ data: [String: String]) -> UserInfo? {
        guard let username = data["username"] else { return nil }
        
        let userType: UserType = data["userType"] == "Admin" ? .administrator : .standard
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let lastPasswordChange = parseDate(data["lastPasswordChange"], formatter: dateFormatter)
        let lastLogin = parseDate(data["lastLogin"], formatter: dateFormatter)
        let lastLogout = parseDate(data["lastLogout"], formatter: dateFormatter)
        let userCreationDate = parseDate(data["userCreationDate"], formatter: dateFormatter)
        
        let passwordHintStatus = data["passwordHintStatus"] ?? "Not Set"
        let secureTokenString = data["secureTokenStatus"] ?? "Unknown"
        let secureTokenStatus = secureTokenString.contains("Enabled") || secureTokenString.contains("enabled")
        
        return UserInfo(
            username: username,
            userType: userType,
            lastPasswordChange: lastPasswordChange,
            lastLogin: lastLogin,
            lastLogout: lastLogout,
            passwordHintStatus: passwordHintStatus,
            secureTokenStatus: secureTokenStatus,
            userCreationDate: userCreationDate
        )
    }
    
    private func parseDate(_ dateString: String?, formatter: DateFormatter) -> Date? {
        guard let dateString = dateString,
              !dateString.isEmpty,
              dateString != "Unknown",
              dateString != "Never",
              dateString != "Never or Unknown",
              dateString != "Still logged in",
              dateString != "shutdown (00:01)",
              dateString != "Unable to determine exactly",
              !dateString.contains("Not available") else { return nil }
        
        // Handle different date formats from the script
        // Format: "Jul 20 21:09 -" or "Jul 16 14:55 -"
        if dateString.contains(" - ") || dateString.hasSuffix(" -") {
            let cleanedDate = dateString.replacingOccurrences(of: " -", with: "")
            let components = cleanedDate.components(separatedBy: " ")
            if components.count >= 3 {
                let month = components[0]
                let day = components[1] 
                let time = components[2]
                
                // Create a date string with current year
                let currentYear = Calendar.current.component(.year, from: Date())
                let dateString = "\(month) \(day), \(currentYear) \(time)"
                
                let customFormatter = DateFormatter()
                customFormatter.dateFormat = "MMM d, yyyy HH:mm"
                return customFormatter.date(from: dateString)
            }
        }
        
        // Handle other formats like "21:09 (00:00)"
        if dateString.contains("(") {
            let cleanedDate = dateString.components(separatedBy: " (").first ?? ""
            if !cleanedDate.isEmpty {
                let customFormatter = DateFormatter()
                customFormatter.dateFormat = "HH:mm"
                return customFormatter.date(from: cleanedDate)
            }
        }
        
        // Try original formatter as fallback
        return formatter.date(from: dateString)
    }
}

struct UserManagerView: View {
    @StateObject private var userManager = UserManager()
    @State private var operationStates: [String: UserOperationState] = [:]
    @State private var statusMessages: [String: String] = [:]
    @State private var searchText = ""
    @State private var selectedUserType = "All"
    @State private var showOnlyAdmins = false
    
    // New user creation
    @State private var showingCreateUserSheet = false
    @State private var newUsername = ""
    @State private var newUserFullName = ""
    @State private var newUserPassword = ""
    @State private var newUserType: UserType = .standard
    
    // Password hint change
    @State private var showingChangeHintSheet = false
    @State private var selectedUserForHint: UserInfo? = nil
    @State private var newPasswordHint = ""
    
    private var userTypes: [String] {
        return ["All", "Administrator", "Standard User"]
    }
    
    private var filteredUsers: [UserInfo] {
        userManager.users.filter { user in
            let matchesSearch = searchText.isEmpty || 
                user.username.localizedCaseInsensitiveContains(searchText)
            
            let matchesType = selectedUserType == "All" || user.userType.rawValue == selectedUserType
            let matchesAdminFilter = !showOnlyAdmins || user.userType == .administrator
            
            return matchesSearch && matchesType && matchesAdminFilter
        }.sorted { first, second in
            // Sort by: admins first, then alphabetically
            if first.userType != second.userType {
                return first.userType == .administrator && second.userType == .standard
            }
            return first.username < second.username
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("User Manager")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.userManager)
                    
                    Text("Manage system users and permissions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { userManager.loadUsers() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .medium))
                            Text("Refresh")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(6)
                    }
                    
                    Button(action: { showingCreateUserSheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 14, weight: .medium))
                            Text("Create User")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // Search and Filters
            VStack(alignment: .leading, spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search users...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Filter Controls
                HStack(spacing: 16) {
                    // User Type Filter
                    HStack(spacing: 8) {
                        Text("Type:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Picker("User Type", selection: $selectedUserType) {
                            ForEach(userTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(minWidth: 120)
                    }
                    
                    // Admin Filter
                    Toggle(isOn: $showOnlyAdmins) {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 12))
                            Text("Admins only")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    
                    Spacer()
                    
                    // Results count
                    Text("\(filteredUsers.count) users")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            
            // Status Messages
            ForEach(Array(statusMessages.keys), id: \.self) { key in
                if let message = statusMessages[key], !message.isEmpty {
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(message.contains("✅") ? .green : message.contains("⚠️") ? .orange : .red)
                        .padding(.horizontal, 24)
                }
            }
            
            // Error Message
            if let errorMessage = userManager.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
            }
            
            // Loading Indicator
            if userManager.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading users...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
            }
            
            // Users List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if filteredUsers.isEmpty && !searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.3")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No users found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Try adjusting your search or filters")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        ForEach(filteredUsers) { user in
                            UserCardView(
                                user: user,
                                operationState: operationStates[user.id] ?? UserOperationState(),
                                statusMessage: statusMessages[user.id] ?? "",
                                onChangePassword: { changePassword(for: user) },
                                onChangeHint: { changeHint(for: user) },
                                onChangeUserType: { changeUserType(for: user) },
                                onToggleSecureToken: { toggleSecureToken(for: user) },
                                onDeleteUser: { deleteUser(user) }
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingCreateUserSheet) {
            CreateUserSheet(
                username: $newUsername,
                fullName: $newUserFullName,
                password: $newUserPassword,
                userType: $newUserType,
                onCreate: { createUser() },
                onCancel: { showingCreateUserSheet = false }
            )
        }
        .sheet(isPresented: $showingChangeHintSheet) {
            ChangePasswordHintSheet(
                username: selectedUserForHint?.username ?? "",
                passwordHint: $newPasswordHint,
                onUpdate: { 
                    performChangeHint()
                    showingChangeHintSheet = false
                },
                onCancel: { showingChangeHintSheet = false }
            )
        }
        .onAppear {
            initializeOperationStates()
        }
        .onChange(of: userManager.users) { _ in
            initializeOperationStates()
        }
    }
    
    private func initializeOperationStates() {
        for user in userManager.users {
            if operationStates[user.id] == nil {
                operationStates[user.id] = UserOperationState()
            }
        }
    }
    
    // MARK: - User Operations
    
    private func changePassword(for user: UserInfo) {
        Logger.shared.logUIEvent("Change password for \(user.username) button tapped", view: "UserManagerView")
        
        operationStates[user.id]?.isChangingPassword = true
        statusMessages[user.id] = "Changing password for \(user.username)..."
        
        Task {
            do {
                let result = try await ExecutionService.executeScript(at: ["/Users/sachinkumar/Desktop/scripts/user_manager.sh", "change_password", user.username, "admin"])
                
                await MainActor.run {
                    operationStates[user.id]?.isChangingPassword = false
                    if result.contains("successfully") {
                        statusMessages[user.id] = "✅ Password changed successfully for \(user.username)!"
                        Logger.shared.info("Password changed for user: \(user.username)", category: "UserManagement")
                    } else {
                        statusMessages[user.id] = "❌ Failed to change password for \(user.username)"
                        Logger.shared.error("Failed to change password for user: \(user.username)", category: "UserManagement")
                    }
                }
            } catch {
                Logger.shared.error("Error changing password for \(user.username): \(error.localizedDescription)", category: "UserManagement")
                await MainActor.run {
                    operationStates[user.id]?.isChangingPassword = false
                    statusMessages[user.id] = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func changeHint(for user: UserInfo) {
        Logger.shared.logUIEvent("Change hint for \(user.username) button tapped", view: "UserManagerView")
        
        selectedUserForHint = user
        newPasswordHint = ""
        showingChangeHintSheet = true
    }
    
    private func performChangeHint() {
        guard let user = selectedUserForHint else { return }
        
        let trimmedHint = newPasswordHint.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedHint.isEmpty {
            statusMessages[user.id] = "❌ Password hint cannot be empty"
            return
        }
        
        operationStates[user.id]?.isChangingHint = true
        statusMessages[user.id] = "Changing password hint for \(user.username)..."
        
        Task {
            do {
                let result = try await ExecutionService.executeScript(at: ["/Users/sachinkumar/Desktop/scripts/change_password_hint.sh", "-u", user.username, "-h", trimmedHint])
                
                await MainActor.run {
                    operationStates[user.id]?.isChangingHint = false
                    if result.contains("updated") || result.contains("successfully") || result.contains("changed") {
                        statusMessages[user.id] = "✅ Password hint updated for \(user.username)!"
                        Logger.shared.info("Password hint changed for user: \(user.username)", category: "UserManagement")
                    } else {
                        statusMessages[user.id] = "❌ Failed to change password hint for \(user.username)"
                        Logger.shared.error("Failed to change password hint for user: \(user.username)", category: "UserManagement")
                    }
                }
            } catch {
                Logger.shared.error("Error changing password hint for \(user.username): \(error.localizedDescription)", category: "UserManagement")
                await MainActor.run {
                    operationStates[user.id]?.isChangingHint = false
                    statusMessages[user.id] = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func changeUserType(for user: UserInfo) {
        Logger.shared.logUIEvent("Change user type for \(user.username) button tapped", view: "UserManagerView")
        
        // Show alert to select new user type
        let alert = NSAlert()
        alert.messageText = "Change User Type"
        alert.informativeText = "Select the new user type for \(user.username):"
        alert.addButton(withTitle: "Make Admin")
        alert.addButton(withTitle: "Make Standard")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        var newType: String?
        var actionDescription: String?
        
        switch response {
        case .alertFirstButtonReturn:
            newType = "admin"
            actionDescription = "Converting \(user.username) to Administrator"
        case .alertSecondButtonReturn:
            newType = "standard" 
            actionDescription = "Converting \(user.username) to Standard User"
        default:
            return // Cancel was clicked
        }
        
        guard let userType = newType, let description = actionDescription else { return }
        
        // Check if user is already the target type
        if (userType == "admin" && user.userType == .administrator) ||
           (userType == "standard" && user.userType == .standard) {
            statusMessages[user.id] = "⚠️ \(user.username) is already a \(user.userType.rawValue)"
            return
        }
        
        operationStates[user.id]?.isChangingUserType = true
        statusMessages[user.id] = description
        
        Task {
            do {
                let result = try await ExecutionService.executeScript(at: ["/Users/sachinkumar/Desktop/scripts/change_user_type.sh", "-u", user.username, "-t", userType])
                
                await MainActor.run {
                    operationStates[user.id]?.isChangingUserType = false
                    if result.contains("successfully") || result.contains("changed") || result.contains("updated") {
                        statusMessages[user.id] = "✅ \(user.username) successfully converted to \(userType == "admin" ? "Administrator" : "Standard User")!"
                        Logger.shared.info("User type changed for user: \(user.username) to \(userType)", category: "UserManagement")
                        userManager.loadUsers() // Refresh to show updated user type
                    } else {
                        statusMessages[user.id] = "❌ Failed to change user type for \(user.username)"
                        Logger.shared.error("Failed to change user type for user: \(user.username)", category: "UserManagement")
                    }
                }
            } catch {
                Logger.shared.error("Error changing user type for \(user.username): \(error.localizedDescription)", category: "UserManagement")
                await MainActor.run {
                    operationStates[user.id]?.isChangingUserType = false
                    statusMessages[user.id] = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func toggleSecureToken(for user: UserInfo) {
        Logger.shared.logUIEvent("Toggle secure token for \(user.username) button tapped", view: "UserManagerView")
        
        operationStates[user.id]?.isChangingSecureToken = true
        let action = user.secureTokenStatus ? "disable" : "enable"
        statusMessages[user.id] = "\(action.capitalized)ing secure token for \(user.username)..."
        
        Task {
            do {
                let result = try await ExecutionService.executeScript(at: ["/Users/sachinkumar/Desktop/scripts/user_manager.sh", "change_secure_token", user.username, action])
                
                await MainActor.run {
                    operationStates[user.id]?.isChangingSecureToken = false
                    if result.contains("enabled") || result.contains("disabled") {
                        statusMessages[user.id] = "✅ Secure token \(action)d for \(user.username)!"
                        Logger.shared.info("Secure token \(action)d for user: \(user.username)", category: "UserManagement")
                        userManager.loadUsers() // Refresh to show updated status
                    } else {
                        statusMessages[user.id] = "❌ Failed to \(action) secure token for \(user.username)"
                        Logger.shared.error("Failed to \(action) secure token for user: \(user.username)", category: "UserManagement")
                    }
                }
            } catch {
                Logger.shared.error("Error changing secure token for \(user.username): \(error.localizedDescription)", category: "UserManagement")
                await MainActor.run {
                    operationStates[user.id]?.isChangingSecureToken = false
                    statusMessages[user.id] = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func deleteUser(_ user: UserInfo) {
        Logger.shared.logUIEvent("Delete \(user.username) button tapped", view: "UserManagerView")
        
        operationStates[user.id]?.isDeletingUser = true
        statusMessages[user.id] = "Deleting user \(user.username)..."
        
        Task {
            do {
                let result = try await ExecutionService.executeScript(at: ["bash", "-c", "echo 'yes' | /Users/sachinkumar/Desktop/scripts/user_manager.sh delete \(user.username)"])
                
                await MainActor.run {
                    operationStates[user.id]?.isDeletingUser = false
                    if result.contains("deleted successfully") {
                        statusMessages[user.id] = "✅ User \(user.username) deleted successfully!"
                        Logger.shared.info("User deleted: \(user.username)", category: "UserManagement")
                        userManager.loadUsers() // Refresh user list
                    } else {
                        statusMessages[user.id] = "❌ Failed to delete user \(user.username)"
                        Logger.shared.error("Failed to delete user: \(user.username)", category: "UserManagement")
                    }
                }
            } catch {
                Logger.shared.error("Error deleting user \(user.username): \(error.localizedDescription)", category: "UserManagement")
                await MainActor.run {
                    operationStates[user.id]?.isDeletingUser = false
                    statusMessages[user.id] = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func createUser() {
        guard !newUsername.isEmpty, !newUserFullName.isEmpty, !newUserPassword.isEmpty else {
            statusMessages["create"] = "❌ Please fill in all fields"
            return
        }
        
        Logger.shared.logUIEvent("Create user \(newUsername) initiated", view: "UserManagerView")
        
        statusMessages["create"] = "Creating user \(newUsername)..."
        
        Task {
            do {
                let userTypeParam = newUserType == .administrator ? "admin" : "standard"
                let result = try await ExecutionService.executeScript(at: ["/Users/sachinkumar/Desktop/scripts/user_manager.sh", "create", newUsername, userTypeParam])
                
                await MainActor.run {
                    if result.contains("created successfully") {
                        statusMessages["create"] = "✅ User \(newUsername) created successfully!"
                        Logger.shared.info("User created: \(newUsername)", category: "UserManagement")
                        
                        // Reset form
                        newUsername = ""
                        newUserFullName = ""
                        newUserPassword = ""
                        newUserType = .standard
                        showingCreateUserSheet = false
                        
                        // Refresh user list
                        userManager.loadUsers()
                    } else {
                        statusMessages["create"] = "❌ Failed to create user \(newUsername)"
                        Logger.shared.error("Failed to create user: \(newUsername)", category: "UserManagement")
                    }
                }
            } catch {
                Logger.shared.error("Error creating user \(newUsername): \(error.localizedDescription)", category: "UserManagement")
                await MainActor.run {
                    statusMessages["create"] = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - UserCardView

struct UserCardView: View {
    let user: UserInfo
    @ObservedObject var operationState: UserOperationState
    let statusMessage: String
    let onChangePassword: () -> Void
    let onChangeHint: () -> Void
    let onChangeUserType: () -> Void
    let onToggleSecureToken: () -> Void
    let onDeleteUser: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Username and Type
                    HStack(spacing: 8) {
                        Image(systemName: user.userType.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(user.userType == .administrator ? .orange : .blue)
                        
                        Text(user.username)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(user.userType.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(user.userType == .administrator ? Color.orange : Color.blue)
                            .cornerRadius(8)
                        
                        if user.secureTokenStatus {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                        }
                    }
                    
                    // User Details Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 2), spacing: 8) {
                        InfoRow(label: "Last Password Change", value: user.formattedLastPasswordChange)
                        InfoRow(label: "Last Login", value: user.formattedLastLogin)
                        InfoRow(label: "Last Logout", value: user.formattedLastLogout)
                        InfoRow(label: "Password Hint", value: user.passwordHintStatus)
                        InfoRow(label: "Secure Token", value: user.secureTokenStatus ? "Enabled" : "Disabled")
                        InfoRow(label: "Created", value: user.formattedUserCreationDate)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        // Change Password Button
                        Button(action: onChangePassword) {
                            HStack(spacing: 4) {
                                if operationState.isChangingPassword {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                } else {
                                    Image(systemName: "key.fill")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                Text(operationState.isChangingPassword ? "Changing" : "Password")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(operationState.isChangingPassword ? Color.gray : Color.blue)
                            .cornerRadius(4)
                        }
                        .disabled(operationState.isChangingPassword)
                        
                        // Change Hint Button
                        Button(action: onChangeHint) {
                            HStack(spacing: 4) {
                                if operationState.isChangingHint {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                } else {
                                    Image(systemName: "questionmark.circle")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                Text(operationState.isChangingHint ? "Updating" : "Hint")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(operationState.isChangingHint ? Color.gray : Color.purple)
                            .cornerRadius(4)
                        }
                        .disabled(operationState.isChangingHint)
                        
                        // Change User Type Button
                        Button(action: onChangeUserType) {
                            HStack(spacing: 4) {
                                if operationState.isChangingUserType {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                } else {
                                    Image(systemName: user.userType == .administrator ? "person.crop.circle.fill.badge.minus" : "person.crop.circle.fill.badge.plus")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                Text(operationState.isChangingUserType ? "Converting" : "Type")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(operationState.isChangingUserType ? Color.gray : Color(red: 0.0, green: 0.588, blue: 0.533))
                            .cornerRadius(4)
                        }
                        .disabled(operationState.isChangingUserType)
                    }
                    
                    HStack(spacing: 8) {
                        // Toggle Secure Token Button
                        Button(action: onToggleSecureToken) {
                            HStack(spacing: 4) {
                                if operationState.isChangingSecureToken {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                } else {
                                    Image(systemName: user.secureTokenStatus ? "lock.slash" : "lock.shield")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                Text(operationState.isChangingSecureToken ? "Updating" : (user.secureTokenStatus ? "Disable" : "Enable"))
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(operationState.isChangingSecureToken ? Color.gray : (user.secureTokenStatus ? Color.orange : Color.green))
                            .cornerRadius(4)
                        }
                        .disabled(operationState.isChangingSecureToken)
                        
                        // Delete User Button
                        Button(action: onDeleteUser) {
                            HStack(spacing: 4) {
                                if operationState.isDeletingUser {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                } else {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                Text(operationState.isDeletingUser ? "Deleting" : "Delete")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(operationState.isDeletingUser ? Color.gray : Color.red)
                            .cornerRadius(4)
                        }
                        .disabled(operationState.isDeletingUser)
                    }
                }
            }
            
            // Status Message
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.system(size: 14))
                    .foregroundColor(statusMessage.contains("✅") ? .green : statusMessage.contains("⚠️") ? .orange : .red)
                    .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

// MARK: - ChangePasswordHintSheet

struct ChangePasswordHintSheet: View {
    let username: String
    @Binding var passwordHint: String
    let onUpdate: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Change Password Hint")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Cancel", action: onCancel)
            }
            .padding(.bottom, 10)
            
            // User info
            Text("User: \(username)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Form Fields
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password Hint")
                        .font(.headline)
                    TextField("Enter new password hint...", text: $passwordHint, onCommit: {
                        if !passwordHint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onUpdate()
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack {
                Spacer()
                
                Button("Cancel", action: onCancel)
                    .foregroundColor(.secondary)
                
                Button("Update Hint") {
                    onUpdate()
                }
                .buttonStyle(DefaultButtonStyle())
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                .disabled(passwordHint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400, height: 250)
    }
}

// MARK: - CreateUserSheet

struct CreateUserSheet: View {
    @Binding var username: String
    @Binding var fullName: String
    @Binding var password: String
    @Binding var userType: UserType
    let onCreate: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Create New User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Cancel", action: onCancel)
            }
            .padding(.bottom, 10)
            
            // Form Fields
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.headline)
                    TextField("Enter username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.headline)
                    TextField("Enter full name", text: $fullName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.headline)
                    SecureField("Enter password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("User Type")
                        .font(.headline)
                    Picker("User Type", selection: $userType) {
                        ForEach(UserType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }.tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack {
                Spacer()
                
                Button("Cancel", action: onCancel)
                    .foregroundColor(.secondary)
                
                Button("Create User") {
                    onCreate()
                }
                .buttonStyle(DefaultButtonStyle())
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                .disabled(username.isEmpty || fullName.isEmpty || password.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400, height: 350)
    }
}