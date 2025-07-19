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

extension UserInfo {
    static let mockUsers: [UserInfo] = [
        UserInfo(
            username: "admin",
            fullName: "System Administrator",
            email: "admin@scriptex.local",
            userType: .admin,
            secureTokenStatus: .enabled,
            lastLoginTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            lastLogoutTime: Calendar.current.date(byAdding: .hour, value: -8, to: Date()),
            lastPasswordChangeTime: Calendar.current.date(byAdding: .day, value: -30, to: Date()),
            lastTerminalSessionTime: Calendar.current.date(byAdding: .minute, value: -45, to: Date()),
            createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        ),
        UserInfo(
            username: "sachinkumar",
            fullName: "Sachin Kumar",
            email: "sachin@scriptex.local",
            userType: .admin,
            secureTokenStatus: .enabled,
            lastLoginTime: Calendar.current.date(byAdding: .minute, value: -30, to: Date()),
            lastLogoutTime: Calendar.current.date(byAdding: .hour, value: -10, to: Date()),
            lastPasswordChangeTime: Calendar.current.date(byAdding: .day, value: -15, to: Date()),
            lastTerminalSessionTime: Calendar.current.date(byAdding: .minute, value: -15, to: Date()),
            createdAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        ),
        UserInfo(
            username: "alexis",
            fullName: "Alexis Bridoux",
            email: "alexis@scriptex.local",
            userType: .admin,
            secureTokenStatus: .enabled,
            lastLoginTime: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
            lastLogoutTime: Calendar.current.date(byAdding: .hour, value: -12, to: Date()),
            lastPasswordChangeTime: Calendar.current.date(byAdding: .day, value: -45, to: Date()),
            lastTerminalSessionTime: Calendar.current.date(byAdding: .minute, value: -20, to: Date()),
            createdAt: Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
        ),
        UserInfo(
            username: "guest",
            fullName: "Guest User",
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
            username: "developer",
            fullName: "Development User",
            email: "dev@scriptex.local",
            userType: .standard,
            secureTokenStatus: .enabled,
            lastLoginTime: Calendar.current.date(byAdding: .hour, value: -6, to: Date()),
            lastLogoutTime: Calendar.current.date(byAdding: .hour, value: -18, to: Date()),
            lastPasswordChangeTime: Calendar.current.date(byAdding: .day, value: -60, to: Date()),
            lastTerminalSessionTime: Calendar.current.date(byAdding: .hour, value: -4, to: Date()),
            createdAt: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date()
        )
    ]
}