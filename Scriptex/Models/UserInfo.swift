import Foundation

// MARK: - UserInfo
struct UserInfo: Codable, Identifiable, Hashable {
    let id: String
    let username: String
    let userType: UserType
    let lastPasswordChange: Date?
    let lastLogin: Date?
    let lastLogout: Date?
    let passwordHintStatus: String
    let secureTokenStatus: Bool
    let userCreationDate: Date?
    
    init(
        username: String,
        userType: UserType = .standard,
        lastPasswordChange: Date? = nil,
        lastLogin: Date? = nil,
        lastLogout: Date? = nil,
        passwordHintStatus: String = "Not Set",
        secureTokenStatus: Bool = false,
        userCreationDate: Date? = nil
    ) {
        self.id = username
        self.username = username
        self.userType = userType
        self.lastPasswordChange = lastPasswordChange
        self.lastLogin = lastLogin
        self.lastLogout = lastLogout
        self.passwordHintStatus = passwordHintStatus
        self.secureTokenStatus = secureTokenStatus
        self.userCreationDate = userCreationDate
    }
    
    var formattedLastPasswordChange: String {
        guard let date = lastPasswordChange else { return "Unknown" }
        return DateFormatter.userInfoFormatter.string(from: date)
    }
    
    var formattedLastLogin: String {
        guard let date = lastLogin else { return "Never" }
        return DateFormatter.userInfoFormatter.string(from: date)
    }
    
    var formattedLastLogout: String {
        guard let date = lastLogout else { return "Unknown" }
        return DateFormatter.userInfoFormatter.string(from: date)
    }
    
    var formattedUserCreationDate: String {
        guard let date = userCreationDate else { return "Unknown" }
        return DateFormatter.userInfoFormatter.string(from: date)
    }
}

// MARK: - UserType
enum UserType: String, Codable, CaseIterable {
    case administrator = "Administrator"
    case standard = "Standard User"
    
    var icon: String {
        switch self {
        case .administrator: return "crown.fill"
        case .standard: return "person.fill"
        }
    }
}

// MARK: - UserOperationState
class UserOperationState: ObservableObject {
    @Published var isChangingPassword = false
    @Published var isChangingHint = false
    @Published var isCreatingUser = false
    @Published var isChangingSecureToken = false
    @Published var isDeletingUser = false
    @Published var isLoadingDetails = false
    @Published var isChangingUserType = false
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let userInfoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}