import SwiftUI

enum ShortcutCategory: String, CaseIterable {
    case all = "All"
    case navigation = "Navigation"
    case editing = "Editing"
    case debugging = "Debugging"
    case building = "Building"
    case interface = "Interface"
    case search = "Search"
    case git = "Git"
    
    var icon: String {
        switch self {
        case .all: return "grid"
        case .navigation: return "arrow.up.arrow.down"
        case .editing: return "pencil"
        case .debugging: return "ladybug"
        case .building: return "hammer"
        case .interface: return "rectangle.3.offgrid"
        case .search: return "magnifyingglass"
        case .git: return "arrow.triangle.branch"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .navigation: return .blue
        case .editing: return .green
        case .debugging: return .red
        case .building: return .orange
        case .interface: return .purple
        case .search: return Color(red: 0.0, green: 0.8, blue: 1.0)
        case .git: return Color(red: 0.6, green: 0.4, blue: 0.2)
        }
    }
}

struct XcodeShortcut: Identifiable {
    let id = UUID()
    let name: String
    let keys: String
    let description: String
    let category: ShortcutCategory
    
    static let allShortcuts: [XcodeShortcut] = [
        // Navigation
        XcodeShortcut(name: "Quick Open", keys: "Cmd + Shift + O", description: "Open file quickly by typing its name", category: .navigation),
        XcodeShortcut(name: "Jump to Definition", keys: "Cmd + Click", description: "Navigate to symbol definition", category: .navigation),
        XcodeShortcut(name: "Go Back", keys: "Cmd + Ctrl + Left", description: "Go back to previous location", category: .navigation),
        XcodeShortcut(name: "Go Forward", keys: "Cmd + Ctrl + Right", description: "Go forward to next location", category: .navigation),
        XcodeShortcut(name: "Jump to Line", keys: "Cmd + L", description: "Jump to specific line number", category: .navigation),
        XcodeShortcut(name: "Show Navigator", keys: "Cmd + 0", description: "Show/hide left navigator panel", category: .navigation),
        XcodeShortcut(name: "Show Inspector", keys: "Cmd + Opt + 0", description: "Show/hide right inspector panel", category: .navigation),
        XcodeShortcut(name: "Show Debug Area", keys: "Cmd + Shift + Y", description: "Show/hide bottom debug area", category: .navigation),
        
        // Editing
        XcodeShortcut(name: "Comment/Uncomment", keys: "Cmd + /", description: "Toggle line or selection comments", category: .editing),
        XcodeShortcut(name: "Indent Right", keys: "Cmd + ]", description: "Increase indentation", category: .editing),
        XcodeShortcut(name: "Indent Left", keys: "Cmd + [", description: "Decrease indentation", category: .editing),
        XcodeShortcut(name: "Move Line Up", keys: "Cmd + Opt + [", description: "Move current line up", category: .editing),
        XcodeShortcut(name: "Move Line Down", keys: "Cmd + Opt + ]", description: "Move current line down", category: .editing),
        XcodeShortcut(name: "Duplicate Line", keys: "Cmd + D", description: "Duplicate current line or selection", category: .editing),
        XcodeShortcut(name: "Delete Line", keys: "Cmd + Shift + K", description: "Delete current line", category: .editing),
        XcodeShortcut(name: "Format Code", keys: "Cmd + I", description: "Re-indent selected code", category: .editing),
        XcodeShortcut(name: "Complete Code", keys: "Esc", description: "Show code completion suggestions", category: .editing),
        
        // Search
        XcodeShortcut(name: "Find", keys: "Cmd + F", description: "Find text in current file", category: .search),
        XcodeShortcut(name: "Find and Replace", keys: "Cmd + Opt + F", description: "Find and replace in current file", category: .search),
        XcodeShortcut(name: "Find in Project", keys: "Cmd + Shift + F", description: "Search across entire project", category: .search),
        XcodeShortcut(name: "Find Next", keys: "Cmd + G", description: "Find next occurrence", category: .search),
        XcodeShortcut(name: "Find Previous", keys: "Cmd + Shift + G", description: "Find previous occurrence", category: .search),
        XcodeShortcut(name: "Use Selection for Find", keys: "Cmd + E", description: "Use selected text for search", category: .search),
        
        // Building
        XcodeShortcut(name: "Build", keys: "Cmd + B", description: "Build the project", category: .building),
        XcodeShortcut(name: "Run", keys: "Cmd + R", description: "Build and run the project", category: .building),
        XcodeShortcut(name: "Stop", keys: "Cmd + .", description: "Stop running or building", category: .building),
        XcodeShortcut(name: "Clean Build Folder", keys: "Cmd + Shift + K", description: "Clean the build folder", category: .building),
        XcodeShortcut(name: "Archive", keys: "Cmd + Shift + Ctrl + A", description: "Archive the project", category: .building),
        XcodeShortcut(name: "Test", keys: "Cmd + U", description: "Run unit tests", category: .building),
        
        // Debugging
        XcodeShortcut(name: "Toggle Breakpoint", keys: "Cmd + \\", description: "Add/remove breakpoint on current line", category: .debugging),
        XcodeShortcut(name: "Step Over", keys: "F6", description: "Step over current line while debugging", category: .debugging),
        XcodeShortcut(name: "Step Into", keys: "F7", description: "Step into function while debugging", category: .debugging),
        XcodeShortcut(name: "Step Out", keys: "F8", description: "Step out of current function", category: .debugging),
        XcodeShortcut(name: "Continue", keys: "Ctrl + Cmd + Y", description: "Continue execution while debugging", category: .debugging),
        XcodeShortcut(name: "Pause", keys: "Ctrl + Cmd + Z", description: "Pause execution while debugging", category: .debugging),
        
        // Interface
        XcodeShortcut(name: "Show Standard Editor", keys: "Cmd + Enter", description: "Show single editor pane", category: .interface),
        XcodeShortcut(name: "Show Assistant Editor", keys: "Cmd + Opt + Enter", description: "Show dual editor panes", category: .interface),
        XcodeShortcut(name: "Hide/Show Utilities", keys: "Cmd + Opt + 0", description: "Toggle right panel visibility", category: .interface),
        XcodeShortcut(name: "Minimize Xcode", keys: "Cmd + M", description: "Minimize Xcode window", category: .interface),
        XcodeShortcut(name: "Preferences", keys: "Cmd + ,", description: "Open Xcode preferences", category: .interface),
        XcodeShortcut(name: "Full Screen", keys: "Cmd + Ctrl + F", description: "Toggle full screen mode", category: .interface),
        
        // Git
        XcodeShortcut(name: "Commit", keys: "Cmd + Opt + C", description: "Open commit dialog", category: .git),
        XcodeShortcut(name: "Push", keys: "Cmd + Opt + P", description: "Push changes to repository", category: .git),
        XcodeShortcut(name: "Pull", keys: "Cmd + Opt + X", description: "Pull changes from repository", category: .git),
        XcodeShortcut(name: "Show Changes", keys: "Cmd + Opt + R", description: "Show repository changes", category: .git),
        XcodeShortcut(name: "Blame", keys: "Cmd + Opt + B", description: "Show git blame for current file", category: .git)
    ]
}

struct CustomShortcut: Identifiable {
    let id = UUID()
    let name: String
    let keys: String
    let description: String
    
    init(name: String, keys: String, description: String) {
        self.name = name
        self.keys = keys
        self.description = description
    }
}