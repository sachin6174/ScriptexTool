import SwiftUI

struct CodeDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let item: SwiftSyntaxItem
    @State private var fontSize: CGFloat = 14
    @State private var showingCopyConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            codeView
            footerView
        }
        .background(AppColors.mainBackground)
        .frame(minWidth: 800, minHeight: 600)
        .alert(isPresented: $showingCopyConfirmation) {
            Alert(
                title: Text("Code Copied"),
                message: Text("The code has been copied to your clipboard."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    HStack(spacing: 8) {
                        Image(systemName: item.category.icon)
                            .foregroundColor(item.category.color)
                        
                        Text(item.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(item.category.color)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    fontSizeControls
                    
                    Button("Copy Code") {
                        copyCode()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            
            Text(item.explanation)
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(nil)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var fontSizeControls: some View {
        HStack(spacing: 8) {
            Button(action: { fontSize = max(10, fontSize - 1) }) {
                Image(systemName: "minus")
                    .font(.caption)
            }
            .disabled(fontSize <= 10)
            
            Text("\(Int(fontSize))pt")
                .font(.caption)
                .frame(width: 30)
            
            Button(action: { fontSize = min(24, fontSize + 1) }) {
                Image(systemName: "plus")
                    .font(.caption)
            }
            .disabled(fontSize >= 24)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
    
    private var codeView: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Swift Code")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Button(action: copyCode) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                        .font(.caption)
                        .foregroundColor(AppColors.primaryAccent)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                SyntaxHighlightedCodeView(
                    code: item.code,
                    fontSize: fontSize
                )
            }
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(12)
        }
        .padding(.horizontal, 24)
    }
    
    private var footerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tips:")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Text("• Copy the code and paste it into Xcode Playground")
                Text("• Modify the code to experiment with different values")
                Text("• Use Cmd+/ to comment/uncomment lines in Xcode")
            }
            .font(.caption)
            .foregroundColor(AppColors.secondaryText)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Character count: \(item.code.count)")
                Text("Line count: \(item.code.components(separatedBy: .newlines).count)")
            }
            .font(.caption)
            .foregroundColor(AppColors.secondaryText)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
    
    private func copyCode() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.code, forType: .string)
        showingCopyConfirmation = true
    }
}

struct SyntaxHighlightedCodeView: View {
    let code: String
    let fontSize: CGFloat
    
    private let swiftKeywords = [
        "import", "class", "struct", "enum", "protocol", "extension",
        "func", "var", "let", "init", "deinit", "self", "super",
        "if", "else", "switch", "case", "default", "for", "while", "repeat",
        "break", "continue", "fallthrough", "return", "throw", "throws",
        "try", "catch", "do", "defer", "guard", "where", "as", "is",
        "true", "false", "nil", "public", "private", "internal", "fileprivate",
        "open", "static", "final", "override", "mutating", "nonmutating",
        "convenience", "required", "lazy", "weak", "unowned", "indirect",
        "associatedtype", "typealias", "inout", "@escaping", "@autoclosure"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(code.components(separatedBy: .newlines).enumerated()), id: \.offset) { index, line in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: fontSize - 2, weight: .regular, design: .monospaced))
                        .foregroundColor(AppColors.secondaryText.opacity(0.6))
                        .frame(minWidth: 25, alignment: .trailing)
                    
                    highlightedLine(line)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .padding(.vertical, 1)
            }
        }
        .padding(16)
    }
    
    @ViewBuilder
    private func highlightedLine(_ line: String) -> some View {
        if line.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
            // Comment line
            Text(line)
                .font(.system(size: fontSize, weight: .regular, design: .monospaced))
                .foregroundColor(.green.opacity(0.8))
        } else if line.trimmingCharacters(in: .whitespaces).hasPrefix("/*") || 
                  line.trimmingCharacters(in: .whitespaces).hasPrefix("*") ||
                  line.trimmingCharacters(in: .whitespaces).hasPrefix("///") {
            // Multi-line comment or documentation
            Text(line)
                .font(.system(size: fontSize, weight: .regular, design: .monospaced))
                .foregroundColor(.green.opacity(0.8))
        } else {
            // Regular code line with syntax highlighting
            syntaxHighlightedText(line)
        }
    }
    
    @ViewBuilder
    private func syntaxHighlightedText(_ line: String) -> some View {
        HStack(spacing: 0) {
            ForEach(highlightedSegments(for: line), id: \.0) { segment, color in
                Text(segment)
                    .font(.system(size: fontSize, weight: .regular, design: .monospaced))
                    .foregroundColor(color)
            }
        }
    }
    
    private func highlightedSegments(for line: String) -> [(String, Color)] {
        var segments: [(String, Color)] = []
        
        // Find all matches for different patterns
        var matches: [(NSRange, Color)] = []
        
        // Keywords
        for _ in swiftKeywords {
            let keywordPattern = "\\b(?:" + swiftKeywords.joined(separator: "|") + ")\\b"
            if let regex = try? NSRegularExpression(pattern: keywordPattern, options: []) {
                let range = NSRange(line.startIndex..<line.endIndex, in: line)
                let keywordMatches = regex.matches(in: line, options: [], range: range)
                for match in keywordMatches {
                    matches.append((match.range, .purple))
                }
            }
            break // Only need to do this once for all keywords
        }
        
        // String literals
        let stringPattern = "\"[^\"]*\""
        if let stringRegex = try? NSRegularExpression(pattern: stringPattern, options: []) {
            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            let stringMatches = stringRegex.matches(in: line, options: [], range: range)
            for match in stringMatches {
                matches.append((match.range, Color.red.opacity(0.8)))
            }
        }
        
        // Numbers
        let numberPattern = "\\b\\d+(\\.\\d+)?\\b"
        if let numberRegex = try? NSRegularExpression(pattern: numberPattern, options: []) {
            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            let numberMatches = numberRegex.matches(in: line, options: [], range: range)
            for match in numberMatches {
                matches.append((match.range, .blue))
            }
        }
        
        // Sort matches by position
        matches.sort { $0.0.location < $1.0.location }
        
        // Build segments
        var lastEnd = 0
        for (range, color) in matches {
            // Add text before the match
            if range.location > lastEnd {
                let beforeRange = NSRange(location: lastEnd, length: range.location - lastEnd)
                if let beforeText = Range(beforeRange, in: line) {
                    let segment = String(line[beforeText])
                    if !segment.isEmpty {
                        segments.append((segment, AppColors.primaryText))
                    }
                }
            }
            
            // Add the highlighted match
            if let matchRange = Range(range, in: line) {
                let segment = String(line[matchRange])
                segments.append((segment, color))
            }
            
            lastEnd = range.location + range.length
        }
        
        // Add remaining text
        if lastEnd < line.count {
            let remainingRange = NSRange(location: lastEnd, length: line.count - lastEnd)
            if let remainingTextRange = Range(remainingRange, in: line) {
                let segment = String(line[remainingTextRange])
                if !segment.isEmpty {
                    segments.append((segment, AppColors.primaryText))
                }
            }
        }
        
        // If no matches found, return the whole line
        if segments.isEmpty {
            segments.append((line, AppColors.primaryText))
        }
        
        return segments
    }
}

