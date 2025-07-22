import SwiftUI

struct XcodeShortcutsView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ShortcutCategory = .all
    @State private var customShortcuts: [CustomShortcut] = []
    @State private var showingAddSheet = false
    
    var filteredShortcuts: [XcodeShortcut] {
        let shortcuts = selectedCategory == .all ? XcodeShortcut.allShortcuts : XcodeShortcut.allShortcuts.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return shortcuts
        } else {
            return shortcuts.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                $0.keys.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            filtersAndSearchView
            shortcutsListView
        }
        .background(AppColors.mainBackground)
        .sheet(isPresented: $showingAddSheet) {
            AddCustomShortcutView { shortcut in
                customShortcuts.append(shortcut)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Xcode Shortcuts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Essential keyboard shortcuts for faster development")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Button(action: { showingAddSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add Custom")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppColors.primaryAccent)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
        .padding(.bottom, 24)
    }
    
    private var filtersAndSearchView: some View {
        VStack(spacing: 16) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.secondaryText)
                    
                    TextField("Search shortcuts...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .frame(maxWidth: 300)
                
                Spacer()
                
                Text("\(filteredShortcuts.count) shortcuts")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ShortcutCategory.allCases, id: \.self) { category in
                        CategoryPillView(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 20)
    }
    
    private var shortcutsListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredShortcuts) { shortcut in
                    ShortcutRowView(shortcut: shortcut)
                }
                
                if !customShortcuts.isEmpty {
                    Section {
                        ForEach(customShortcuts) { customShortcut in
                            CustomShortcutRowView(shortcut: customShortcut) {
                                customShortcuts.removeAll { $0.id == customShortcut.id }
                            }
                        }
                    } header: {
                        HStack {
                            Text("Custom Shortcuts")
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            Spacer()
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

struct CategoryPillView: View {
    let category: ShortcutCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? AppColors.primaryAccent : Color(NSColor.controlBackgroundColor))
            .foregroundColor(isSelected ? .white : AppColors.primaryText)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShortcutRowView: View {
    let shortcut: XcodeShortcut
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(shortcut.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text(shortcut.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(shortcut.category.color.opacity(0.2))
                        .foregroundColor(shortcut.category.color)
                        .cornerRadius(4)
                }
                
                Text(shortcut.description)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                KeyCombinationView(keys: shortcut.keys)
                
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(shortcut.keys, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Copy shortcut")
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct KeyCombinationView: View {
    let keys: String
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(keys.components(separatedBy: " + "), id: \.self) { key in
                Text(key.replacingOccurrences(of: "Cmd", with: "⌘")
                        .replacingOccurrences(of: "Opt", with: "⌥")
                        .replacingOccurrences(of: "Shift", with: "⇧")
                        .replacingOccurrences(of: "Ctrl", with: "⌃"))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(4)
                    .foregroundColor(AppColors.primaryText)
            }
        }
    }
}