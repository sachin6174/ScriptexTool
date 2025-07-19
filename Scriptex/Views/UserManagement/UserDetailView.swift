import SwiftUI

struct UserDetailView: View {
    let user: UserInfo
    let onUserUpdated: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingPasswordChange = false
    @State private var showingPasswordHintChange = false
    @State private var showingSecureTokenChange = false
    @State private var operationInProgress = false
    @State private var statusMessage = ""
    @State private var showStatusMessage = false
    @State private var detailedUserInfo: String? = nil
    @State private var isLoadingDetails = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        basicInfoSection
                        securitySection
                        activitySection
                        if let detailedInfo = detailedUserInfo {
                            detailedInfoSection(detailedInfo)
                        }
                        sessionHistorySection
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
            .background(AppColors.mainBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Actions") {
                        Button("Change Password") {
                            showingPasswordChange = true
                        }
                        .disabled(!user.isActive || operationInProgress)
                        
                        Button("Change Password Hint") {
                            showingPasswordHintChange = true
                        }
                        .disabled(!user.isActive || operationInProgress)
                        
                        Divider()
                        
                        if user.secureTokenStatus.rawValue == "Disabled" {
                            Button("Enable Secure Token") {
                                showingSecureTokenChange = true
                            }
                            .disabled(operationInProgress)
                        } else {
                            Button("Disable Secure Token") {
                                showingSecureTokenChange = true
                            }
                            .disabled(operationInProgress)
                        }
                    }
                    .disabled(!user.isActive && user.secureTokenStatus.rawValue == "Disabled")
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            loadDetailedUserInfo()
        }
        .sheet(isPresented: $showingPasswordChange) {
            PasswordChangeView(
                user: user,
                onPasswordChanged: {
                    statusMessage = "✅ Password changed successfully for \(user.username)"
                    showStatusMessage = true
                    onUserUpdated()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showStatusMessage = false
                    }
                }
            )
        }
        .sheet(isPresented: $showingPasswordHintChange) {
            PasswordHintChangeView(
                user: user,
                onHintChanged: {
                    statusMessage = "✅ Password hint updated for \(user.username)"
                    showStatusMessage = true
                    onUserUpdated()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showStatusMessage = false
                    }
                }
            )
        }
        .sheet(isPresented: $showingSecureTokenChange) {
            SecureTokenChangeView(
                user: user,
                onTokenChanged: {
                    statusMessage = "✅ Secure token status updated for \(user.username)"
                    showStatusMessage = true
                    onUserUpdated()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showStatusMessage = false
                    }
                }
            )
        }
        .overlay(
            Group {
                if showStatusMessage {
                    VStack {
                        Spacer()
                        Text(statusMessage)
                            .font(.system(size: 14))
                            .foregroundColor(statusMessage.contains("✅") ? .green : .red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .padding(.bottom, 20)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                userAvatarView
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Text(user.fullName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                        
                        if !user.isActive {
                            Text("INACTIVE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text("@\(user.username)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    if let email = user.email {
                        Text(email)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: user.userType.icon)
                            .font(.system(size: 14))
                            .foregroundColor(Color(user.userType.color))
                        
                        Text(user.userType.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                    }
                }
                
                Spacer()
            }
            
            Divider()
        }
        .padding(.horizontal, 32)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    private var userAvatarView: some View {
        ZStack {
            Circle()
                .fill(Color(user.userType.color))
                .frame(width: 80, height: 80)
            
            Image(systemName: user.userType.icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    private var basicInfoSection: some View {
        DetailSectionView(title: "Basic Information", icon: "person.crop.circle") {
            VStack(spacing: 16) {
                DetailRowView(
                    label: "Full Name",
                    value: user.fullName,
                    icon: "person.fill"
                )
                
                DetailRowView(
                    label: "Username",
                    value: user.username,
                    icon: "at"
                )
                
                if let email = user.email {
                    DetailRowView(
                        label: "Email",
                        value: email,
                        icon: "envelope.fill"
                    )
                }
                
                DetailRowView(
                    label: "User Type",
                    value: user.userType.rawValue,
                    icon: user.userType.icon,
                    valueColor: Color(user.userType.color)
                )
                
                DetailRowView(
                    label: "Account Status",
                    value: user.isActive ? "Active" : "Inactive",
                    icon: user.isActive ? "checkmark.circle.fill" : "xmark.circle.fill",
                    valueColor: user.isActive ? .green : .red
                )
                
                DetailRowView(
                    label: "Created",
                    value: formatDate(user.createdAt),
                    icon: "calendar"
                )
            }
        }
    }
    
    private var securitySection: some View {
        DetailSectionView(title: "Security", icon: "shield.checkered") {
            VStack(spacing: 16) {
                DetailRowView(
                    label: "Secure Token",
                    value: user.secureTokenStatus.rawValue,
                    icon: user.secureTokenStatus.icon,
                    valueColor: Color(user.secureTokenStatus.color)
                )
                
                if let lastPasswordChange = user.lastPasswordChangeTime {
                    DetailRowView(
                        label: "Password Last Changed",
                        value: formatDate(lastPasswordChange),
                        icon: "key.fill"
                    )
                } else {
                    DetailRowView(
                        label: "Password Last Changed",
                        value: "Never",
                        icon: "key.fill",
                        valueColor: .orange
                    )
                }
            }
        }
    }
    
    private var activitySection: some View {
        DetailSectionView(title: "Activity", icon: "clock") {
            VStack(spacing: 16) {
                if let lastLogin = user.lastLoginTime {
                    DetailRowView(
                        label: "Last Login",
                        value: formatDateWithRelative(lastLogin),
                        icon: "arrow.right.circle.fill"
                    )
                } else {
                    DetailRowView(
                        label: "Last Login",
                        value: "Never",
                        icon: "arrow.right.circle",
                        valueColor: .orange
                    )
                }
                
                if let lastLogout = user.lastLogoutTime {
                    DetailRowView(
                        label: "Last Logout",
                        value: formatDateWithRelative(lastLogout),
                        icon: "arrow.left.circle.fill"
                    )
                } else {
                    DetailRowView(
                        label: "Last Logout",
                        value: "Unknown",
                        icon: "arrow.left.circle",
                        valueColor: .secondary
                    )
                }
                
                if let lastTerminalSession = user.lastTerminalSessionTime {
                    DetailRowView(
                        label: "Last Terminal Session",
                        value: formatDateWithRelative(lastTerminalSession),
                        icon: "terminal.fill"
                    )
                } else {
                    DetailRowView(
                        label: "Last Terminal Session",
                        value: "Never",
                        icon: "terminal",
                        valueColor: .orange
                    )
                }
            }
        }
    }
    
    private var sessionHistorySection: some View {
        DetailSectionView(title: "Session History", icon: "list.bullet.rectangle") {
            VStack(spacing: 12) {
                Text("Recent login sessions would be displayed here")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Placeholder for session history
                ForEach(0..<3, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Terminal Session \(index + 1)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("192.168.1.\(100 + index)")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.tertiaryText)
                        }
                        
                        Spacer()
                        
                        Text("\(index + 1)h ago")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDateWithRelative(_ date: Date) -> String {
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .abbreviated
        let relative = relativeFormatter.localizedString(for: date, relativeTo: Date())
        
        let absoluteFormatter = DateFormatter()
        absoluteFormatter.dateStyle = .short
        absoluteFormatter.timeStyle = .short
        let absolute = absoluteFormatter.string(from: date)
        
        return "\(relative) (\(absolute))"
    }
    
    private func detailedInfoSection(_ details: String) -> some View {
        DetailSectionView(title: "System Details", icon: "info.circle") {
            VStack(alignment: .leading, spacing: 12) {
                Text(details)
                    .font(.system(size: 12, family: .monospaced))
                    .foregroundColor(AppColors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .cornerRadius(8)
            }
        }
    }
    
    private func loadDetailedUserInfo() {
        isLoadingDetails = true
        
        Task {
            do {
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/user_manager.sh"
                let result = try await ExecutionService.executeScript(at: [
                    "sudo", scriptPath, "get_details", user.username
                ])
                
                await MainActor.run {
                    isLoadingDetails = false
                    // Format the output for better display
                    detailedUserInfo = formatDetailedInfo(result)
                }
            } catch {
                await MainActor.run {
                    isLoadingDetails = false
                    detailedUserInfo = "Error loading details: \(error.localizedDescription)"
                    Logger.shared.error("Failed to load detailed user info: \(error.localizedDescription)", category: "UserManagement")
                }
            }
        }
    }
    
    private func formatDetailedInfo(_ rawOutput: String) -> String {
        // Remove ANSI color codes and format for display
        let cleanOutput = rawOutput
            .replacingOccurrences(of: "\u{001B}\[[0-9;]*m", with: "", options: .regularExpression)
            .replacingOccurrences(of: "===", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanOutput
    }
}

struct DetailSectionView<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryAccent)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
            }
            
            VStack(spacing: 0) {
                content()
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
            )
        }
    }
}

struct DetailRowView: View {
    let label: String
    let value: String
    let icon: String
    var valueColor: Color = AppColors.primaryText
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
                .frame(width: 140, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Password Change View

struct PasswordChangeView: View {
    let user: UserInfo
    let onPasswordChanged: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var useAdminCredentials = true
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isChanging = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Change Password for \(user.username)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                    .padding(.top, 20)
                
                Toggle("Use Admin Credentials", isOn: $useAdminCredentials)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    if !useAdminCredentials {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.primaryText)
                            
                            SecureField("Enter current password", text: $currentPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                        
                        SecureField("Enter new password", text: $newPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm New Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                        
                        SecureField("Confirm new password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
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
                    
                    Button("Change Password") {
                        changePassword()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isChanging || newPassword.isEmpty || newPassword != confirmPassword || (!useAdminCredentials && currentPassword.isEmpty))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(width: 400, height: 400)
            .navigationBarHidden(true)
        }
    }
    
    private func changePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isChanging = true
        errorMessage = ""
        
        Task {
            do {
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/user_manager.sh"
                let method = useAdminCredentials ? "admin" : "user"
                
                let result: String
                if useAdminCredentials {
                    // For admin method, only need new password
                    result = try await ExecutionService.executeScript(at: [
                        "bash", "-c",
                        "echo '\(newPassword)' | sudo \(scriptPath) change_password \(user.username) \(method)"
                    ])
                } else {
                    // For user method, need current password then new password
                    result = try await ExecutionService.executeScript(at: [
                        "bash", "-c",
                        "printf '\(currentPassword)\n\(newPassword)\n' | sudo \(scriptPath) change_password \(user.username) \(method)"
                    ])
                }
                
                await MainActor.run {
                    isChanging = false
                    if result.contains("changed successfully") {
                        onPasswordChanged()
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        errorMessage = "Failed to change password. Please check credentials."
                    }
                }
                
                Logger.shared.logAppOperation(appName: "UserManagement", operation: "change_password", success: result.contains("changed successfully"))
            } catch {
                await MainActor.run {
                    isChanging = false
                    errorMessage = "Error changing password: \(error.localizedDescription)"
                }
                Logger.shared.error("Failed to change password for \(user.username): \(error.localizedDescription)", category: "UserManagement")
            }
        }
    }
}

// MARK: - Password Hint Change View

struct PasswordHintChangeView: View {
    let user: UserInfo
    let onHintChanged: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var passwordHint = ""
    @State private var isChanging = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Change Password Hint for \(user.username)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password Hint")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                    
                    TextField("Enter password hint", text: $passwordHint)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    
                    Button("Update Hint") {
                        changeHint()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isChanging || passwordHint.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(width: 400, height: 300)
            .navigationBarHidden(true)
        }
    }
    
    private func changeHint() {
        isChanging = true
        errorMessage = ""
        
        Task {
            do {
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/user_manager.sh"
                let result = try await ExecutionService.executeScript(at: [
                    "bash", "-c",
                    "printf '\(passwordHint)\n' | sudo \(scriptPath) change_hint \(user.username)"
                ])
                
                await MainActor.run {
                    isChanging = false
                    if result.contains("updated") {
                        onHintChanged()
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        errorMessage = "Failed to update password hint."
                    }
                }
                
                Logger.shared.logAppOperation(appName: "UserManagement", operation: "change_hint", success: result.contains("updated"))
            } catch {
                await MainActor.run {
                    isChanging = false
                    errorMessage = "Error updating hint: \(error.localizedDescription)"
                }
                Logger.shared.error("Failed to change hint for \(user.username): \(error.localizedDescription)", category: "UserManagement")
            }
        }
    }
}

// MARK: - Secure Token Change View

struct SecureTokenChangeView: View {
    let user: UserInfo
    let onTokenChanged: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var adminUsername = ""
    @State private var adminPassword = ""
    @State private var isChanging = false
    @State private var errorMessage = ""
    
    private var isEnabling: Bool {
        user.secureTokenStatus.rawValue == "Disabled"
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(isEnabling ? "Enable" : "Disable") Secure Token for \(user.username)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                    .padding(.top, 20)
                
                Text("This operation requires admin credentials.")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Admin Username")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                        
                        TextField("Enter admin username", text: $adminUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Admin Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                        
                        SecureField("Enter admin password", text: $adminPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
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
                    
                    Button(isEnabling ? "Enable" : "Disable") {
                        changeSecureToken()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isChanging || adminUsername.isEmpty || adminPassword.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(width: 400, height: 350)
            .navigationBarHidden(true)
        }
    }
    
    private func changeSecureToken() {
        isChanging = true
        errorMessage = ""
        
        Task {
            do {
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/user_manager.sh"
                let action = isEnabling ? "enable" : "disable"
                let result = try await ExecutionService.executeScript(at: [
                    "bash", "-c",
                    "printf '\(adminUsername)\n\(adminPassword)\n' | sudo \(scriptPath) change_secure_token \(user.username) \(action)"
                ])
                
                await MainActor.run {
                    isChanging = false
                    if result.contains(isEnabling ? "enabled" : "disabled") {
                        onTokenChanged()
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        errorMessage = "Failed to \(action) secure token. Check admin credentials."
                    }
                }
                
                Logger.shared.logAppOperation(appName: "UserManagement", operation: "change_secure_token", success: result.contains(isEnabling ? "enabled" : "disabled"))
            } catch {
                await MainActor.run {
                    isChanging = false
                    errorMessage = "Error changing secure token: \(error.localizedDescription)"
                }
                Logger.shared.error("Failed to change secure token for \(user.username): \(error.localizedDescription)", category: "UserManagement")
            }
        }
    }
}