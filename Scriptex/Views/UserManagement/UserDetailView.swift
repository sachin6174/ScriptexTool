import SwiftUI

struct UserDetailView: View {
    let user: UserInfo
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        basicInfoSection
                        securitySection
                        activitySection
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
                    Button("Edit") {
                        // Edit functionality
                    }
                    .disabled(!user.isActive)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
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