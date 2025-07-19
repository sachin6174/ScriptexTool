import SwiftUI

struct DashboardView: View {
    @Binding var networkInfo: NetworkInfo
    @Binding var systemInfo: SystemInfo
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header Section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dashboard")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("System information and status")
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        // Quick Actions
                        HStack(spacing: 12) {
                            Button(action: {}) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.primaryAccent)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {}) {
                                Image(systemName: "gear")
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
                
                // Cards Grid
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        NetworkInfoCard(networkInfo: $networkInfo)
                            .frame(minHeight: 180)
                        
                        StorageInfoCard()
                            .frame(minHeight: 180)
                    }
                    
                    SystemInfoCard(systemInfo: $systemInfo)
                        .frame(minHeight: 200)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .background(AppColors.mainBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}