import SwiftUI

struct AddCustomShortcutView: View {
    @Environment(\.presentationMode) var presentationMode
    let onAdd: (CustomShortcut) -> Void
    
    @State private var name = ""
    @State private var keys = ""
    @State private var description = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !keys.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            formView
            footerView
        }
        .background(AppColors.mainBackground)
        .frame(width: 500, height: 400)
        .alert(isPresented: $showingError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Add Custom Shortcut")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.secondaryText)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text("Create a custom keyboard shortcut reference")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var formView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Shortcut Name")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                
                TextField("e.g., Custom Build Script", text: $name)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Key Combination")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Button(action: showKeyHelper) {
                        Text("Key Helper")
                            .font(.caption)
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                TextField("e.g., Cmd + Shift + B", text: $keys)
                    .textFieldStyle(CustomTextFieldStyle())
                
                Text("Use format: Cmd + Shift + Key (or ⌘ + ⇧ + Key)")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                
                TextField("Describe what this shortcut does", text: $description)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            if !isValid {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Please fill in all fields")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var footerView: some View {
        HStack {
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Spacer()
            
            Button("Add Shortcut") {
                addCustomShortcut()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!isValid)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
    
    private func addCustomShortcut() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKeys = keys.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let shortcut = CustomShortcut(
            name: trimmedName,
            keys: trimmedKeys,
            description: trimmedDescription
        )
        
        onAdd(shortcut)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func showKeyHelper() {
        let helpText = """
        Common modifier keys:
        • Cmd or ⌘ - Command key
        • Shift or ⇧ - Shift key
        • Opt or ⌥ - Option/Alt key
        • Ctrl or ⌃ - Control key
        
        Examples:
        • Cmd + C
        • Cmd + Shift + O
        • Ctrl + Opt + F
        • ⌘ + ⇧ + ⌥ + K
        """
        
        let alert = NSAlert()
        alert.messageText = "Keyboard Shortcut Format"
        alert.informativeText = helpText
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

struct CustomShortcutRowView: View {
    let shortcut: CustomShortcut
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(shortcut.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text("Custom")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppColors.primaryAccent.opacity(0.2))
                        .foregroundColor(AppColors.primaryAccent)
                        .cornerRadius(4)
                }
                
                Text(shortcut.description)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                KeyCombinationView(keys: shortcut.keys)
                
                HStack(spacing: 8) {
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
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete shortcut")
                }
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.secondaryText.opacity(0.2), lineWidth: 1)
            )
    }
}

