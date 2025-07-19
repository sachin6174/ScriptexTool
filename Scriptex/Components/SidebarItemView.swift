import SwiftUI

struct SidebarItemView: View {
    let item: SidebarItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSelected ? AppColors.sidebarText : item.color)
                    .frame(width: 20)
                
                Text(item.rawValue)
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(isSelected ? Color(NSColor.selectedMenuItemTextColor) : AppColors.sidebarText)
                
                Spacer()
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(item.color)
                        .frame(width: 3, height: 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? 
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(NSColor.selectedContentBackgroundColor),
                                Color(NSColor.selectedContentBackgroundColor).opacity(0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.0 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}