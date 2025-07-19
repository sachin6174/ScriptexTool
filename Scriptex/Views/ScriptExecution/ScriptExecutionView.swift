import SwiftUI
import UniformTypeIdentifiers

struct ScriptExecutionView: View {
    @State private var scriptPath = ""
    @State private var scriptOutput = ""
    @State private var isDropTarget = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Script Execution")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.scriptExecution)
                
                Text("Execute shell scripts and automation tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TextField("/script/path", text: $scriptPath)
                        .textFieldStyle(.roundedBorder)
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
                    Button("Execute") {
                        executeScript()
                        ContentView.executeAsyncCommand(at: ["/Users/sachinkumar/a.sh"]) { chunk, isLast, pid in
                            if isLast {
                                print("sachinPID \(pid) has finished executing a.sh.")
                            } else {
                                if !chunk.isEmpty {
                                    print("sachinPID \(pid) output chunk:\(chunk)")
                                }
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.buttonGradient(for: AppColors.scriptExecution))
                    .cornerRadius(6)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                
                Text("Output:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextEditor(text: $scriptOutput)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .frame(minHeight: 200)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
    
    @MainActor
    private func executeScript() {
        guard !scriptPath.isEmpty else { 
            Logger.shared.warning("Script execution attempted with empty path", category: "UI")
            return 
        }

        Logger.shared.logUIEvent("Script execution button tapped", view: "ScriptExecutionView", details: ["scriptPath": scriptPath])

        Task {
            do {
                Logger.shared.info("Starting script execution from UI", category: "UI")
                let result = try await ExecutionService.executeScript(at: [scriptPath])
                scriptOutput = result
                Logger.shared.info("Script execution completed successfully from UI", category: "UI")
            } catch {
                scriptOutput = error.localizedDescription
                Logger.shared.error("Script execution failed from UI: \(error.localizedDescription)", category: "UI")
            }
        }
    }
}