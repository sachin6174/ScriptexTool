import SwiftUI
import UniformTypeIdentifiers

struct ScriptExecutionView: View {
    @State private var scriptPath = ""
    @State private var scriptOutput = ""
    @State private var isDropTarget = false
    @State private var selectedReturnType: ScriptReturnType = .integer
    @State private var showingPredefinedScripts = true
    @State private var isExecuting = false
    @State private var lastExecutedScript: PredefinedScript?
    
    var filteredScripts: [PredefinedScript] {
        PredefinedScript.scripts(for: selectedReturnType)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left sidebar with script library
            predefinedScriptsPanel
            
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1)
            
            // Right panel with custom execution and output
            customScriptPanel
        }
        .background(AppColors.mainBackground)
    }
    
    private var predefinedScriptsPanel: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "terminal.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.scriptExecution)
                    
                    Text("Script Library")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryText)
                }
                
                Text("Ready-to-run scripts organized by return type")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                
                // Return type selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ScriptReturnType.allCases, id: \.self) { returnType in
                            ReturnTypePill(
                                returnType: returnType,
                                isSelected: selectedReturnType == returnType,
                                count: PredefinedScript.scripts(for: returnType).count
                            ) {
                                selectedReturnType = returnType
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Scripts list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredScripts) { script in
                        ScriptRowView(
                            script: script,
                            isExecuting: isExecuting && lastExecutedScript?.id == script.id
                        ) {
                            executePredefinedScript(script)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 350, maxWidth: 350)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var customScriptPanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Custom Script Execution")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Execute your own shell scripts and commands")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
            
            // Custom script input
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TextField("Enter script path or drag & drop file here", text: $scriptPath)
                        .textFieldStyle(CustomScriptTextFieldStyle())
                        .onDrop(of: [.fileURL], isTargeted: $isDropTarget) { providers in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                                guard
                                    let data,
                                    let path = URL(dataRepresentation: data, relativeTo: nil)
                                else { return }
                                scriptPath = path.path
                            }
                            return true
                        }
                    
                    Button(action: executeCustomScript) {
                        HStack(spacing: 6) {
                            if isExecuting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "play.fill")
                            }
                            Text(isExecuting ? "Running..." : "Execute")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(isExecuting ? Color.gray : AppColors.scriptExecution)
                        .cornerRadius(8)
                    }
                    .disabled(isExecuting || scriptPath.isEmpty)
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Output section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Output")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        if !scriptOutput.isEmpty {
                            Button("Clear") {
                                scriptOutput = ""
                                lastExecutedScript = nil
                            }
                            .font(.caption)
                            .foregroundColor(AppColors.primaryAccent)
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Button("Copy") {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(scriptOutput, forType: .string)
                        }
                        .font(.caption)
                        .foregroundColor(AppColors.primaryAccent)
                        .buttonStyle(PlainButtonStyle())
                        .disabled(scriptOutput.isEmpty)
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            if let lastScript = lastExecutedScript {
                                HStack {
                                    Image(systemName: lastScript.returnType.icon)
                                        .foregroundColor(Color(lastScript.returnType.color))
                                    
                                    Text("[\(lastScript.returnType.rawValue)] \(lastScript.name)")
                                        .font(.caption)
                                        .foregroundColor(AppColors.secondaryText)
                                    
                                    Spacer()
                                }
                                .padding(.bottom, 4)
                            }
                            
                            Text(scriptOutput.isEmpty ? "No output yet. Select a predefined script or enter a custom command." : scriptOutput)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(scriptOutput.isEmpty ? AppColors.secondaryText : AppColors.primaryText)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
                    .frame(minHeight: 300)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
    
    @MainActor
    private func executeCustomScript() {
        guard !scriptPath.isEmpty else {
            Logger.shared.warning("Script execution attempted with empty path", category: "UI")
            return
        }
        
        isExecuting = true
        lastExecutedScript = nil
        
        Logger.shared.logUIEvent("Custom script execution button tapped", view: "ScriptExecutionView", details: ["scriptPath": scriptPath])
        
        Task {
            do {
                Logger.shared.info("Starting custom script execution from UI", category: "UI")
                let result = try await ExecutionService.executeScript(at: [scriptPath])
                scriptOutput = result
                Logger.shared.info("Custom script execution completed successfully from UI", category: "UI")
            } catch {
                scriptOutput = "Error: \(error.localizedDescription)"
                Logger.shared.error("Custom script execution failed from UI: \(error.localizedDescription)", category: "UI")
            }
            isExecuting = false
        }
    }
    
    @MainActor
    private func executePredefinedScript(_ script: PredefinedScript) {
        isExecuting = true
        lastExecutedScript = script
        
        Logger.shared.logUIEvent("Predefined script execution", view: "ScriptExecutionView", details: ["scriptName": script.name, "returnType": script.returnType.rawValue])
        
        Task {
            do {
                Logger.shared.info("Starting predefined script execution: \(script.name)", category: "UI")
                let result = try await ExecutionService.executeCommand(script.command)
                scriptOutput = result.trimmingCharacters(in: .whitespacesAndNewlines)
                Logger.shared.info("Predefined script execution completed: \(script.name)", category: "UI")
            } catch {
                scriptOutput = "Error executing \(script.name): \(error.localizedDescription)"
                Logger.shared.error("Predefined script execution failed: \(script.name) - \(error.localizedDescription)", category: "UI")
            }
            isExecuting = false
        }
    }
}

// MARK: - Supporting Views

struct ReturnTypePill: View {
    let returnType: ScriptReturnType
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: returnType.icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(returnType.rawValue)
                    .font(.system(size: 12, weight: .medium))
                
                Text("(\(count))")
                    .font(.system(size: 10, weight: .regular))
                    .opacity(0.7)
            }
            .foregroundColor(isSelected ? .white : Color(returnType.color))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color(returnType.color) : Color(returnType.color).opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ScriptRowView: View {
    let script: PredefinedScript
    let isExecuting: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: script.returnType.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(script.returnType.color))
                            .frame(width: 16)
                        
                        Text(script.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if isExecuting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.6)
                        }
                    }
                    
                    Text(script.description)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(script.category)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(script.returnType.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(script.returnType.color).opacity(0.15))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Text(script.returnType.rawValue.uppercased())
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color(script.returnType.color))
                            .cornerRadius(3)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(isExecuting ? Color(script.returnType.color).opacity(0.1) : Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(script.returnType.color).opacity(isExecuting ? 0.5 : 0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isExecuting)
    }
}

struct CustomScriptTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
            )
    }
}