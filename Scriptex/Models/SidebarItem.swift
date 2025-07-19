import SwiftUI

enum SidebarItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case scriptExecution = "Script Execution"
    case appManager = "App Manager"
    case fileManager = "File Manager"
    case userManagement = "User Management"
    
    var icon: String {
        switch self {
        case .dashboard: return "gauge.badge.plus"
        case .scriptExecution: return "terminal"
        case .appManager: return "app.badge"
        case .fileManager: return "folder"
        case .userManagement: return "person.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .dashboard: return AppColors.dashboard
        case .scriptExecution: return AppColors.scriptExecution
        case .appManager: return AppColors.appManager
        case .fileManager: return AppColors.fileManager
        case .userManagement: return AppColors.quaternaryAccent
        }
    }
}