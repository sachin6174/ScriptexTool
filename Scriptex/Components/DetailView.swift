import SwiftUI

// User Management Implementation
struct UserInfo: Identifiable, Codable {
    let id: UUID
    let username: String
    let fullName: String
    let email: String?
    let userType: UserType
    let secureTokenStatus: SecureTokenStatus
    let lastLoginTime: Date?
    let lastLogoutTime: Date?
    let lastPasswordChangeTime: Date?
    let lastTerminalSessionTime: Date?
    let createdAt: Date
    let isActive: Bool
    
    static let mockUsers: [UserInfo] = [
        UserInfo(
            id: UUID(),
            username: "admin",
            fullName: "System Administrator",
            email: "admin@scriptex.local",
            userType: .admin,
            secureTokenStatus: .enabled,
            lastLoginTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            lastLogoutTime: Calendar.current.date(byAdding: .hour, value: -8, to: Date()),
            lastPasswordChangeTime: Calendar.current.date(byAdding: .day, value: -30, to: Date()),
            lastTerminalSessionTime: Calendar.current.date(byAdding: .minute, value: -45, to: Date()),
            createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            isActive: true
        ),
        UserInfo(
            id: UUID(),
            username: "sachinkumar",
            fullName: "Sachin Kumar",
            email: "sachin@scriptex.local",
            userType: .admin,
            secureTokenStatus: .enabled,
            lastLoginTime: Calendar.current.date(byAdding: .minute, value: -30, to: Date()),
            lastLogoutTime: Calendar.current.date(byAdding: .hour, value: -10, to: Date()),
            lastPasswordChangeTime: Calendar.current.date(byAdding: .day, value: -15, to: Date()),
            lastTerminalSessionTime: Calendar.current.date(byAdding: .minute, value: -15, to: Date()),
            createdAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
            isActive: true
        ),
        UserInfo(
            id: UUID(),
            username: "guest",
            fullName: "Guest User",
            email: nil,
            userType: .standard,
            secureTokenStatus: .disabled,
            lastLoginTime: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
            lastLogoutTime: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
            lastPasswordChangeTime: nil,
            lastTerminalSessionTime: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            createdAt: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            isActive: false
        ),
        UserInfo(
            id: UUID(),
            username: "developer",
            fullName: "Development User",
            email: "dev@scriptex.local",
            userType: .standard,
            secureTokenStatus: .enabled,
            lastLoginTime: Calendar.current.date(byAdding: .hour, value: -6, to: Date()),
            lastLogoutTime: Calendar.current.date(byAdding: .hour, value: -18, to: Date()),
            lastPasswordChangeTime: Calendar.current.date(byAdding: .day, value: -60, to: Date()),
            lastTerminalSessionTime: Calendar.current.date(byAdding: .hour, value: -4, to: Date()),
            createdAt: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(),
            isActive: true
        )
    ]
}

enum UserType: String, CaseIterable, Codable {
    case admin = "Administrator"
    case standard = "Standard"
    
    var icon: String {
        switch self {
        case .admin: return "crown.fill"
        case .standard: return "person.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .admin: return .red
        case .standard: return .blue
        }
    }
}

enum SecureTokenStatus: String, CaseIterable, Codable {
    case enabled = "Enabled"
    case disabled = "Disabled"
    case unknown = "Unknown"
    
    var icon: String {
        switch self {
        case .enabled: return "checkmark.shield.fill"
        case .disabled: return "xmark.shield.fill"
        case .unknown: return "questionmark.shield.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .enabled: return .green
        case .disabled: return .red
        case .unknown: return .orange
        }
    }
}

struct UserManagementView: View {
    @State private var users = UserInfo.mockUsers
    @State private var searchText = ""
    @State private var selectedUserType: UserType? = nil
    @State private var selectedUser: UserInfo? = nil
    @State private var showingUserDetail = false
    
    var filteredUsers: [UserInfo] {
        var filteredUsers = users
        
        if !searchText.isEmpty {
            filteredUsers = filteredUsers.filter { user in
                user.username.localizedCaseInsensitiveContains(searchText) ||
                user.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.email?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        if let selectedUserType = selectedUserType {
            filteredUsers = filteredUsers.filter { $0.userType == selectedUserType }
        }
        
        return filteredUsers.sorted { $0.username < $1.username }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            controlsSection
            userListView
        }
        .background(AppColors.mainBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingUserDetail) {
            if let selectedUser = selectedUser {
                UserDetailView(user: selectedUser)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("User Management")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("System users and access information")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        // Refresh users
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
        .padding(.bottom, 28)
    }
    
    private var controlsSection: some View {
        HStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.secondaryText)
                    .font(.system(size: 14))
                
                TextField("Search users...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .frame(maxWidth: 300)
            
            Picker("User Type", selection: $selectedUserType) {
                Text("All Users").tag(nil as UserType?)
                ForEach(UserType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type as UserType?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: 200)
            
            Spacer()
            
            Text("\(filteredUsers.count) users")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 20)
    }
    
    private var userListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(filteredUsers) { user in
                    UserRowView(user: user) {
                        selectedUser = user
                        showingUserDetail = true
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

struct UserRowView: View {
    let user: UserInfo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                userAvatarView
                userInfoSection
                Spacer()
                userDetailsSection
                chevronView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: AppColors.cardShadow, radius: 4, x: 0, y: 2)
    }
    
    private var userAvatarView: some View {
        ZStack {
            Circle()
                .fill(user.userType.color)
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
    
    private var userDetailsSection: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Last Login")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.tertiaryText)
                    if let lastLogin = user.lastLoginTime {
                        Text(formatRelativeTime(lastLogin))
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.secondaryText)
                    } else {
                        Text("Never")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                    }
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Last Logout")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.tertiaryText)
                    if let lastLogout = user.lastLogoutTime {
                        Text(formatRelativeTime(lastLogout))
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.secondaryText)
                    } else {
                        Text("Unknown")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                    }
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Password Changed")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.tertiaryText)
                    if let lastPasswordChange = user.lastPasswordChangeTime {
                        Text(formatRelativeTime(lastPasswordChange))
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.secondaryText)
                    } else {
                        Text("Never")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                    }
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Terminal Session")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.tertiaryText)
                    if let lastTerminal = user.lastTerminalSessionTime {
                        Text(formatRelativeTime(lastTerminal))
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.secondaryText)
                    } else {
                        Text("Never")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                    }
                }
            }
            
            HStack(spacing: 4) {
                Image(systemName: user.secureTokenStatus.icon)
                    .font(.system(size: 12))
                    .foregroundColor(user.secureTokenStatus.color)
                
                Text(user.secureTokenStatus.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
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

struct UserDetailView: View {
    let user: UserInfo
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("User Details: \(user.fullName)")
                    .font(.largeTitle)
                
                Spacer()
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(DefaultButtonStyle())
                .foregroundColor(.white)
                .background(AppColors.primaryAccent)
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(label: "Username", value: user.username)
                    DetailRow(label: "Full Name", value: user.fullName)
                    DetailRow(label: "Email", value: user.email ?? "Not provided")
                    DetailRow(label: "User Type", value: user.userType.rawValue)
                    DetailRow(label: "Secure Token", value: user.secureTokenStatus.rawValue)
                    DetailRow(label: "Account Status", value: user.isActive ? "Active" : "Inactive")
                    
                    if let lastLogin = user.lastLoginTime {
                        DetailRow(label: "Last Login", value: formatDate(lastLogin))
                    }
                    if let lastLogout = user.lastLogoutTime {
                        DetailRow(label: "Last Logout", value: formatDate(lastLogout))
                    }
                    if let lastPasswordChange = user.lastPasswordChangeTime {
                        DetailRow(label: "Password Changed", value: formatDate(lastPasswordChange))
                    }
                    if let lastTerminal = user.lastTerminalSessionTime {
                        DetailRow(label: "Terminal Session", value: formatDate(lastTerminal))
                    }
                    
                    DetailRow(label: "Created", value: formatDate(user.createdAt))
                }
                .padding()
            }
            
            Spacer()
        }
        .frame(minWidth: 500, minHeight: 400)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
                .frame(width: 140, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct DetailView: View {
    let selectedItem: SidebarItem
    @Binding var networkInfo: NetworkInfo
    @Binding var systemInfo: SystemInfo
    
    var body: some View {
        Group {
            switch selectedItem {
            case .dashboard:
                DashboardView(networkInfo: $networkInfo, systemInfo: $systemInfo)
            case .scriptExecution:
                ScriptExecutionView()
            case .appManager:
                AppManagerView()
            case .fileManager:
                FileManagerView()
            case .userManagement:
                UserManagementView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.mainBackground)
    }
}