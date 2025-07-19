import Foundation

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
    let lastPasswordHintChange: Date?
    let createdAt: Date
    let isActive: Bool
    
    init(
        id: UUID = UUID(),
        username: String,
        fullName: String,
        email: String? = nil,
        userType: UserType,
        secureTokenStatus: SecureTokenStatus,
        lastLoginTime: Date? = nil,
        lastLogoutTime: Date? = nil,
        lastPasswordChangeTime: Date? = nil,
        lastTerminalSessionTime: Date? = nil,
        lastPasswordHintChange: Date? = nil,
        createdAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.username = username
        self.fullName = fullName
        self.email = email
        self.userType = userType
        self.secureTokenStatus = secureTokenStatus
        self.lastLoginTime = lastLoginTime
        self.lastLogoutTime = lastLogoutTime
        self.lastPasswordChangeTime = lastPasswordChangeTime
        self.lastTerminalSessionTime = lastTerminalSessionTime
        self.lastPasswordHintChange = lastPasswordHintChange
        self.createdAt = createdAt
        self.isActive = isActive
    }
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
    
    var color: String {
        switch self {
        case .admin: return "systemRed"
        case .standard: return "systemBlue"
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
    
    var color: String {
        switch self {
        case .enabled: return "systemGreen"
        case .disabled: return "systemRed"
        case .unknown: return "systemOrange"
        }
    }
}

// MARK: - UserInfo Extensions

extension UserInfo {
    /// Sample data for testing purposes only - not used in production
    static let sampleUsers: [UserInfo] = []
}