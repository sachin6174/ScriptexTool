import SwiftUI

struct SwiftSyntaxView: View {
    @State private var searchText = ""
    @State private var selectedCategory: SyntaxCategory = .basics
    @State private var selectedItem: SwiftSyntaxItem? = nil
    @State private var showingCodeDetail = false
    
    var filteredItems: [SwiftSyntaxItem] {
        let items = SwiftSyntaxItem.allSyntaxItems.filter { item in
            selectedCategory == .basics ? true : item.category == selectedCategory
        }
        
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.explanation.localizedCaseInsensitiveContains(searchText) ||
                item.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            sidebarView
            
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1)
            
            mainContentView
        }
        .background(AppColors.mainBackground)
        .sheet(isPresented: $showingCodeDetail) {
            if let item = selectedItem {
                CodeDetailView(item: item)
            }
        }
    }
    
    private var sidebarView: some View {
        VStack(spacing: 0) {
            sidebarHeader
            categoryList
        }
        .frame(minWidth: 280, maxWidth: 280)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var sidebarHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "swift")
                    .font(.title2)
                    .foregroundColor(AppColors.secondaryAccent)
                
                Text("Swift Syntax")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.secondaryText)
                
                TextField("Search syntax...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var categoryList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(SyntaxCategory.allCases, id: \.self) { category in
                    CategoryRowView(
                        category: category,
                        isSelected: selectedCategory == category,
                        itemCount: SwiftSyntaxItem.allSyntaxItems.filter { $0.category == category }.count
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            mainHeader
            syntaxItemsList
        }
    }
    
    private var mainHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedCategory.rawValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                
                Text("\\(filteredItems.count) syntax examples")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: copyAllCode) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy All")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.primaryAccent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.primaryAccent.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: exportToPlayground) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.secondaryAccent)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
        .padding(.bottom, 20)
    }
    
    private var syntaxItemsList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(filteredItems) { item in
                    SyntaxItemView(item: item) {
                        selectedItem = item
                        showingCodeDetail = true
                    }
                    .animation(.easeInOut(duration: 0.2), value: filteredItems.count)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .animation(.easeInOut(duration: 0.3), value: selectedCategory)
    }
    
    private func copyAllCode() {
        let allCode = filteredItems.map { item in
            "// \(item.title)\n\(item.code)"
        }.joined(separator: "\n\n")
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(allCode, forType: .string)
    }
    
    private func exportToPlayground() {
        let allCode = filteredItems.map { item in
            """
            /*
             \(item.title)
             \(item.explanation)
             */
            
            \(item.code)
            """
        }.joined(separator: "\n\n")
        
        let savePanel = NSSavePanel()
        savePanel.title = "Export Swift Syntax"
        savePanel.nameFieldStringValue = "\(selectedCategory.rawValue.replacingOccurrences(of: " ", with: "")).playground"
        savePanel.allowedContentTypes = [.init(filenameExtension: "playground") ?? .plainText]
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            do {
                try allCode.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to export: \\(error)")
            }
        }
    }
}

struct CategoryRowView: View {
    let category: SyntaxCategory
    let isSelected: Bool
    let itemCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : category.color)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .white : AppColors.primaryText)
                        .lineLimit(1)
                    
                    Text("\\(itemCount) examples")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : AppColors.secondaryText)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? category.color : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SyntaxItemView: View {
    let item: SwiftSyntaxItem
    let onTap: () -> Void
    
    private var codeLineCount: Int {
        return item.code.components(separatedBy: .newlines).count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: item.category.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(item.category.color)
                        
                        Text(item.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(item.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(item.category.color.opacity(0.15))
                            .foregroundColor(item.category.color)
                            .cornerRadius(4)
                        
                        Button(action: copyCode) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Copy code")
                        
                        Button(action: onTap) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primaryAccent)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("View details")
                    }
                }
                
                Text(item.explanation)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Code section with adaptive height
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Swift Code")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text("\(codeLineCount) lines")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.secondaryText.opacity(0.7))
                }
                
                CodePreviewView(code: item.code)
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.category.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func copyCode() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.code, forType: .string)
    }
}

struct CodePreviewView: View {
    let code: String
    
    private var codeLines: [String] {
        return code.components(separatedBy: .newlines)
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(codeLines.enumerated()), id: \.offset) { index, line in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1)")
                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                            .foregroundColor(AppColors.secondaryText.opacity(0.6))
                            .frame(minWidth: 20, alignment: .trailing)
                        
                        Text(line.isEmpty ? " " : line)
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundColor(AppColors.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                    }
                    .padding(.vertical, 1)
                }
            }
            .padding(12)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .frame(
            minHeight: CGFloat(min(codeLines.count * 18 + 24, 50)),
            idealHeight: CGFloat(min(codeLines.count * 18 + 24, 400)),
            maxHeight: CGFloat(min(codeLines.count * 18 + 24, 500))
        )
    }
}