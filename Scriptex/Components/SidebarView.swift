import SwiftUI

struct SidebarView: View {
    @Binding var selectedItem: SidebarItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "terminal.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.primaryAccent)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scriptex")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(AppColors.sidebarText)
                        
                        Text("Automation Tools")
                            .font(.system(size: 11, weight: .medium, design: .default))
                            .foregroundColor(AppColors.sidebarSecondaryText)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 8)
                
                // Subtle divider
                Rectangle()
                    .fill(Color(NSColor.separatorColor))
                    .frame(height: 0.5)
                    .padding(.horizontal, 20)
            }
            
            // Navigation Items
            VStack(spacing: 1) {
                ForEach(SidebarItem.allCases, id: \.self) { item in
                    SidebarItemView(
                        item: item,
                        isSelected: selectedItem == item,
                        action: { selectedItem = item }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 20)
            
            Spacer()
            
            // Footer
            VStack(alignment: .leading, spacing: 12) {
                Rectangle()
                    .fill(Color(NSColor.separatorColor))
                    .frame(height: 0.5)
                    .padding(.horizontal, 20)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Version 1.0")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(AppColors.sidebarSecondaryText)
                        
                        Text("© 2025 Scriptex")
                            .font(.system(size: 9, weight: .regular, design: .default))
                            .foregroundColor(AppColors.sidebarSecondaryText.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(AppColors.sidebarBackground)
        .frame(minWidth: 220, maxWidth: 220)
    }
}