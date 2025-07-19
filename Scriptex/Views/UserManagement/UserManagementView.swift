import SwiftUI

struct UserManagementView: View {
    @StateObject private var userService = UserManagementService.shared
    @State private var searchText = ""
    @State private var selectedUserType: UserType? = nil
    @State private var selectedUser: UserInfo? = nil
    @State private var showingUserDetail = false
    
    var filteredUsers: [UserInfo] {
        var users = userService.users
        
        if !searchText.isEmpty {
            users = users.filter { user in
                user.username.localizedCaseInsensitiveContains(searchText) ||
                user.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.email?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        if let selectedUserType = selectedUserType {
            users = users.filter { $0.userType == selectedUserType }
        }
        
        return users.sorted { $0.username < $1.username }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            controlsSection
            
            if userService.isLoading {
                loadingView
            } else if let errorMessage = userService.errorMessage {
                errorView(errorMessage)
            } else {
                userListView
            }
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
                        userService.refreshUsers()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .buttonStyle(.plain)
                    .disabled(userService.isLoading)
                    
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
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading users...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(AppColors.quaternaryAccent)
            
            Text("Error Loading Users")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                userService.refreshUsers()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var userListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 1) {
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
                userStatusSection
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