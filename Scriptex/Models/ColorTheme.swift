import SwiftUI

struct AppColors {
    // MARK: - Modern macOS System Colors
    
    // Primary accent colors following macOS design
    static let primaryAccent = Color(red: 0.0, green: 0.478, blue: 1.0) // SF Blue
    static let secondaryAccent = Color(red: 0.196, green: 0.843, blue: 0.294) // SF Green
    static let tertiaryAccent = Color(red: 1.0, green: 0.584, blue: 0.0) // SF Orange
    static let quaternaryAccent = Color(red: 1.0, green: 0.271, blue: 0.227) // SF Pink
    
    // MARK: - Card Colors
    static let networkCard = primaryAccent
    static let storageCard = secondaryAccent
    static let systemCard = tertiaryAccent
    static let performanceCard = quaternaryAccent
    
    // Legacy support
    static let dashboard = primaryAccent
    static let scriptExecution = secondaryAccent
    static let appManager = tertiaryAccent
    static let fileManager = quaternaryAccent
    
    // MARK: - Background System
    static let sidebarBackground = LinearGradient(
        gradient: Gradient(colors: [
            Color(NSColor.controlBackgroundColor),
            Color(NSColor.controlBackgroundColor).opacity(0.95)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let mainBackground = LinearGradient(
        gradient: Gradient(colors: [
            Color(NSColor.windowBackgroundColor),
            Color(NSColor.windowBackgroundColor).opacity(0.95)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Material Effects
    static func cardBackground(for color: Color) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(NSColor.controlBackgroundColor),
                color.opacity(0.03)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func selectionBackground(for color: Color) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                color.opacity(0.15),
                color.opacity(0.08)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography Colors
    static let primaryText = Color(NSColor.labelColor)
    static let secondaryText = Color(NSColor.secondaryLabelColor)
    static let tertiaryText = Color(NSColor.tertiaryLabelColor)
    static let sidebarText = Color(NSColor.labelColor)
    static let sidebarSecondaryText = Color(NSColor.secondaryLabelColor)
    
    // MARK: - Shadow System
    static let cardShadow = Color.black.opacity(0.06)
    static let elevatedShadow = Color.black.opacity(0.12)
    static let deepShadow = Color.black.opacity(0.18)
    
    // MARK: - Legacy Support Methods
    static func buttonGradient(for color: Color) -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [color, color.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func selectionGradient(for color: Color) -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [color.opacity(0.15), color.opacity(0.08)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}