import SwiftUI

enum SidebarItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case scriptExecution = "Script Execution"
    case appManager = "App Manager"
    case userManager = "User Manager"
    case fileManager = "File Manager"
    
    var icon: String {
        switch self {
        case .dashboard: return "gauge.badge.plus"
        case .scriptExecution: return "terminal"
        case .appManager: return "app.badge"
        case .userManager: return "person.3"
        case .fileManager: return "folder"
        }
    }
    
    var color: Color {
        switch self {
        case .dashboard: return AppColors.dashboard
        case .scriptExecution: return AppColors.scriptExecution
        case .appManager: return AppColors.appManager
        case .userManager: return AppColors.userManager
        case .fileManager: return AppColors.fileManager
        }
    }
}