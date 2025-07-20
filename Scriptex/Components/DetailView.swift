import SwiftUI


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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.mainBackground)
    }
}
