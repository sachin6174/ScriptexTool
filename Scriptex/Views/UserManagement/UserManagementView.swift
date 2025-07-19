import SwiftUI

// MARK: - User Operation State
struct UserOperationState {
    var isProcessing: Bool = false
    var lastOperation: String? = nil
    var operationProgress: Double = 0.0
}

enum UserOperation: String, CaseIterable {
    case changePassword = "Change Password"
    case changeHint = "Change Hint"
    case toggleSecureToken = "Toggle Secure Token"
    case delete = "Delete"
    case viewDetails = "View Details"
}

struct UserManagementView: View {
    @StateObject private var userService = UserManagementService.shared
    @State private var searchText = ""
    @State private var selectedUserType = "All"
    @State private var showOnlyActive = false
    @State private var selectedUser: UserInfo? = nil
    @State private var showingUserDetail = false
    @State private var showingCreateUser = false
    @State private var operationStates: [String: UserOperationState] = [:]
    @State private var statusMessages: [String: String] = [:]
    
    private var userTypes: [String] {
        let types = Set(userService.users.map { $0.userType.rawValue })
        return ["All"] + Array(types).sorted()
    }
    
    private var filteredUsers: [UserInfo] {
        userService.users.filter { user in
            let matchesSearch = searchText.isEmpty || 
                user.username.localizedCaseInsensitiveContains(searchText) ||
                user.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.email?.localizedCaseInsensitiveContains(searchText) == true
            
            let matchesType = selectedUserType == "All" || user.userType.rawValue == selectedUserType
            let matchesActiveFilter = !showOnlyActive || user.isActive
            
            return matchesSearch && matchesType && matchesActiveFilter
        }.sorted { first, second in
            // Sort by: active first, then admin, then alphabetically
            if first.isActive != second.isActive {
                return first.isActive && !second.isActive
            }
            if first.userType != second.userType {
                return first.userType == .admin && second.userType == .standard
            }
            return first.username < second.username
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("User Management")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Manage system users and access control")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { testScript() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "terminal")
                                .font(.system(size: 14, weight: .medium))
                            Text("Test Script")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(6)
                    }
                    
                    Button(action: { userService.refreshUsers() }) {
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
                    
                    Button(action: { showingCreateUser = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .medium))
                            Text("Add User")
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
                    
                    // Active Filter
                    Toggle(isOn: $showOnlyActive) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 12))
                            Text("Active only")
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
                if let message = statusMessages[key] {
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(message.contains("✅") ? .green : .red)
                        .padding(.horizontal, 24)
                }
            }
            
            // Error Message
            if let errorMessage = userService.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
            }
            
            // Loading Indicator
            if userService.isLoading {
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
                            Image(systemName: "magnifyingglass")
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
                                operationState: operationStates[user.username] ?? UserOperationState(),
                                onViewDetails: {
                                    selectedUser = user
                                    showingUserDetail = true
                                },
                                onDelete: {
                                    deleteUser(user.username)
                                },
                                onOperationStateChange: { state in
                                    operationStates[user.username] = state
                                },
                                onStatusMessage: { message in
                                    statusMessages[user.username] = message
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        statusMessages.removeValue(forKey: user.username)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(AppColors.mainBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingUserDetail) {
            if let selectedUser = selectedUser {
                UserDetailView(user: selectedUser, onUserUpdated: {
                    userService.refreshUsers()
                })
            }
        }
        .sheet(isPresented: $showingCreateUser) {
            CreateUserView(onUserCreated: {
                userService.refreshUsers()
            })
        }
    }
    
    
    
    
    
    
    
    // MARK: - User Management Operations
    
    private func deleteUser(_ username: String) {
        operationStates[username] = UserOperationState(isProcessing: true, lastOperation: "Deleting...")
        
        Task {
            do {
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/user_manager.sh"
                let result = try await ExecutionService.executeScript(at: [
                    "bash", "-c", "echo 'yes' | sudo \(scriptPath) delete \(username)"
                ])
                
                await MainActor.run {
                    operationStates[username] = UserOperationState()
                    if result.contains("deleted successfully") {
                        statusMessages[username] = "✅ User '\(username)' deleted successfully"
                        userService.refreshUsers()
                    } else {
                        statusMessages[username] = "❌ Failed to delete user '\(username)'"
                    }
                }
                
                Logger.shared.logAppOperation(appName: "UserManagement", operation: "delete_user", success: result.contains("deleted successfully"))
            } catch {
                await MainActor.run {
                    operationStates[username] = UserOperationState()
                    statusMessages[username] = "❌ Error deleting user: \(error.localizedDescription)"
                }
                Logger.shared.error("Failed to delete user \(username): \(error.localizedDescription)", category: "UserManagement")
            }
        }
    }
    
    // Test script execution
    private func testScript() {
        statusMessages["script_test"] = "Testing script..."
        
        Task {
            let result = await userService.testScriptExecution()
            
            await MainActor.run {
                statusMessages["script_test"] = result
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    statusMessages.removeValue(forKey: "script_test")
                }
            }
        }
    }
}

// MARK: - User Card View

struct UserCardView: View {
    let user: UserInfo
    let operationState: UserOperationState
    let onViewDetails: () -> Void
    let onDelete: () -> Void
    let onOperationStateChange: (UserOperationState) -> Void
    let onStatusMessage: (String) -> Void
    
    @State private var showingPasswordChange = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // User Header
            HStack(spacing: 16) {
                userAvatarView
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(user.fullName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                        
                        // User type badge
                        Text(user.userType.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(user.userType.color))
                            .cornerRadius(4)
                        
                        if !user.isActive {
                            Text("INACTIVE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text("@\(user.username)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    if let email = user.email {
                        Text(email)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
                
                Spacer()
                
                // Status indicators
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: user.secureTokenStatus.icon)
                            .font(.system(size: 12))
                            .foregroundColor(Color(user.secureTokenStatus.color))
                        
                        Text(user.secureTokenStatus.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    if let lastLogin = user.lastLoginTime {
                        Text("Last login: \(formatRelativeTime(lastLogin))")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
            }
            
            // Operation Progress
            if operationState.isProcessing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(operationState.lastOperation ?? "Processing...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onViewDetails) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                        Text("Details")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                }
                
                Button(action: { showingPasswordChange = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "key")
                            .font(.system(size: 12))
                        Text("Password")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
                
                Spacer()
                
                Button(action: { showingDeleteConfirmation = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                        Text("Delete")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
                .disabled(!user.isActive || operationState.isProcessing)
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
        .shadow(color: AppColors.cardShadow, radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingPasswordChange) {
            if let selectedUser = Optional(user) {
                PasswordChangeView(
                    user: selectedUser,
                    onPasswordChanged: {
                        onStatusMessage("✅ Password changed successfully for \(user.username)")
                    }
                )
            }
        }
        .alert("Delete User", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to permanently delete user '\(user.username)' and their home directory? This action cannot be undone.")
        }
    }
    
    private var userAvatarView: some View {
        ZStack {
            Circle()
                .fill(Color(user.userType.color))
                .frame(width: 54, height: 54)
            
            Image(systemName: user.userType.icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// Keep existing UserRowView for compatibility
struct UserRowView: View {
    let user: UserInfo
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onTap) {
                HStack(spacing: 16) {
                    userAvatarView
                    userInfoSection
                    Spacer()
                    userStatusSection
                    chevronView
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
        .shadow(color: AppColors.cardShadow, radius: 4, x: 0, y: 2)
    }
    
    private var userAvatarView: some View {
        ZStack {
            Circle()
                .fill(Color(user.userType.color))
                .frame(width: 44, height: 44)
            
            Image(systemName: user.userType.icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(user.fullName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                if !user.isActive {
                    Text("INACTIVE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }
            
            Text("@\(user.username)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            if let email = user.email {
                Text(email)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
    }
    
    private var userStatusSection: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: user.secureTokenStatus.icon)
                    .font(.system(size: 12))
                    .foregroundColor(Color(user.secureTokenStatus.color))
                
                Text(user.secureTokenStatus.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            if let lastLogin = user.lastLoginTime {
                Text("Last login: \(formatRelativeTime(lastLogin))")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
    }
    
    private var chevronView: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(AppColors.tertiaryText)
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Create User View

struct CreateUserView: View {
    @Environment(\.presentationMode) var presentationMode
    let onUserCreated: () -> Void
    
    @State private var username = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isAdmin = false
    @State private var isCreating = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Create New User")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                        
                        TextField("Enter username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                        
                        TextField("Enter full name", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                        
                        SecureField("Enter password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                        
                        SecureField("Confirm password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Toggle("Administrator Account", isOn: $isAdmin)
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Create User") {
                        createUser()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCreating || username.isEmpty || fullName.isEmpty || password.isEmpty || password != confirmPassword)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(width: 400, height: 500)
            .navigationBarHidden(true)
        }
    }
    
    private func createUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isCreating = true
        errorMessage = ""
        
        Task {
            do {
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/user_manager.sh"
                let userType = isAdmin ? "admin" : "standard"
                
                // Create the user using the script
                let result = try await ExecutionService.executeScript(at: [
                    "bash", "-c", 
                    "printf '\(fullName)\n\(password)\n' | sudo \(scriptPath) create \(username) \(userType)"
                ])
                
                await MainActor.run {
                    isCreating = false
                    if result.contains("created successfully") {
                        onUserCreated()
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        errorMessage = "Failed to create user. Check if username already exists."
                    }
                }
                
                Logger.shared.logAppOperation(appName: "UserManagement", operation: "create_user", success: result.contains("created successfully"))
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = "Error creating user: \(error.localizedDescription)"
                }
                Logger.shared.error("Failed to create user \(username): \(error.localizedDescription)", category: "UserManagement")
            }
        }
    }
}

extension Color {
    init(_ colorName: String) {
        switch colorName {
        case "systemRed": self = .red
        case "systemBlue": self = .blue
        case "systemGreen": self = .green
        case "systemOrange": self = .orange
        default: self = .gray
        }
    }
}