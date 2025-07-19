import SwiftUI

struct AppManagerView: View {
    @State private var isInstallingVSCode = false
    @State private var isInstallingAnyDesk = false
    @State private var vsCodeStatus = ""
    @State private var anyDeskStatus = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("App Manager")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.appManager)
                    
                    Text("Manage and monitor applications")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Available Applications")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                // VS Code Installation Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Visual Studio Code")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Microsoft's lightweight code editor")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            installVSCode()
                        }) {
                            HStack(spacing: 6) {
                                if isInstallingVSCode {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.down.circle")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                Text(isInstallingVSCode ? "Installing..." : "Install")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isInstallingVSCode ? Color.gray : AppColors.primaryAccent)
                            .cornerRadius(6)
                        }
                        .disabled(isInstallingVSCode)
                    }
                }
                .padding(16)
                .background(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(8)
                
                // VS Code Installation Status
                if !vsCodeStatus.isEmpty {
                    Text(vsCodeStatus)
                        .font(.system(size: 14))
                        .foregroundColor(vsCodeStatus.contains("Error") ? .red : .green)
                        .padding(.top, 8)
                }
                
                // AnyDesk Installation Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AnyDesk")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Remote desktop access software")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            installAnyDesk()
                        }) {
                            HStack(spacing: 6) {
                                if isInstallingAnyDesk {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.down.circle")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                Text(isInstallingAnyDesk ? "Installing..." : "Install")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isInstallingAnyDesk ? Color.gray : AppColors.secondaryAccent)
                            .cornerRadius(6)
                        }
                        .disabled(isInstallingAnyDesk)
                    }
                }
                .padding(16)
                .background(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(8)
                
                // AnyDesk Installation Status
                if !anyDeskStatus.isEmpty {
                    Text(anyDeskStatus)
                        .font(.system(size: 14))
                        .foregroundColor(anyDeskStatus.contains("Error") ? .red : .green)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            Spacer()
        }
    }
    
    private func installVSCode() {
        Logger.shared.logUIEvent("Install VS Code button tapped", view: "AppManagerView")
        
        isInstallingVSCode = true
        vsCodeStatus = "Downloading VS Code..."
        
        Task {
            do {
                Logger.shared.info("Starting VS Code installation", category: "AppInstallation")
                let vsCodeURL = "https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"
                
                // Download the DMG file
                await MainActor.run {
                    vsCodeStatus = "Downloading VS Code DMG..."
                }
                
                let downloadedPath = try await downloadFile(from: vsCodeURL, fileName: "VSCode.zip")
                
                // Install using the script
                await MainActor.run {
                    vsCodeStatus = "Installing VS Code..."
                }
                
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/universal_installer.sh"
                Logger.shared.info("Executing VS Code installation script", category: "AppInstallation")
                let result = try await ExecutionService.executeScript(at: [scriptPath,"-f" ,downloadedPath])
                
                await MainActor.run {
                    isInstallingVSCode = false
                    if result.contains("completed successfully") {
                        vsCodeStatus = "✅ VS Code installed successfully!"
                        Logger.shared.logAppInstallation(appName: "VS Code", success: true)
                    } else {
                        vsCodeStatus = "❌ Installation failed. Check console for details."
                        Logger.shared.logAppInstallation(appName: "VS Code", success: false)
                    }
                }
            } catch {
                Logger.shared.logAppInstallation(appName: "VS Code", success: false, error: error)
                await MainActor.run {
                    isInstallingVSCode = false
                    vsCodeStatus = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func installAnyDesk() {
        Logger.shared.logUIEvent("Install AnyDesk button tapped", view: "AppManagerView")
        
        isInstallingAnyDesk = true
        anyDeskStatus = "Downloading AnyDesk..."
        
        Task {
            do {
                Logger.shared.info("Starting AnyDesk installation", category: "AppInstallation")
                let anyDeskURL = "https://download.anydesk.com/anydesk.dmg"
                
                // Download the DMG file
                await MainActor.run {
                    anyDeskStatus = "Downloading AnyDesk DMG..."
                }
                
                let downloadedPath = try await downloadFile(from: anyDeskURL, fileName: "AnyDesk.dmg")
                
                // Install using the script
                await MainActor.run {
                    anyDeskStatus = "Installing AnyDesk..."
                }
                
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/universal_installer.sh"
                Logger.shared.info("Executing AnyDesk installation script", category: "AppInstallation")
                let result = try await ExecutionService.executeScript(at: [scriptPath, "-f", downloadedPath])
                
                await MainActor.run {
                    isInstallingAnyDesk = false
                    if result.contains("completed successfully") {
                        anyDeskStatus = "✅ AnyDesk installed successfully!"
                        Logger.shared.logAppInstallation(appName: "AnyDesk", success: true)
                    } else {
                        anyDeskStatus = "❌ Installation failed. Check console for details."
                        Logger.shared.logAppInstallation(appName: "AnyDesk", success: false)
                    }
                }
            } catch {
                Logger.shared.logAppInstallation(appName: "AnyDesk", success: false, error: error)
                await MainActor.run {
                    isInstallingAnyDesk = false
                    anyDeskStatus = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func downloadFile(from urlString: String, fileName: String) async throws -> String {
        Logger.shared.info("Starting download from \(urlString)", category: "Download")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        guard let url = URL(string: urlString) else {
            Logger.shared.error("Invalid URL: \(urlString)", category: "Download")
            throw NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let downloadTask = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
                if let error = error {
                    let duration = CFAbsoluteTimeGetCurrent() - startTime
                    Logger.shared.logDownload(url: urlString, success: false, error: error, duration: duration)
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let tempURL = tempURL else {
                    continuation.resume(throwing: NSError(domain: "DownloadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No temporary URL received"]))
                    return
                }
                
                do {
                    let tempDir = URL(fileURLWithPath: "/var/tmp")
                    let namedTempURL = tempDir.appendingPathComponent(fileName)
                    
                    // Remove existing temp file if it exists
                    if FileManager.default.fileExists(atPath: namedTempURL.path) {
                        try FileManager.default.removeItem(at: namedTempURL)
                    }
                    
                    // Move to temp location with proper filename
                    try FileManager.default.moveItem(at: tempURL, to: namedTempURL)
                    
                    let duration = CFAbsoluteTimeGetCurrent() - startTime
                    let fileSize = (try? FileManager.default.attributesOfItem(atPath: namedTempURL.path)[.size] as? Int64) ?? 0
                    Logger.shared.logDownload(url: urlString, success: true, filePath: namedTempURL.path, duration: duration, fileSize: fileSize)
                    
                    continuation.resume(returning: namedTempURL.path)
                } catch {
                    let duration = CFAbsoluteTimeGetCurrent() - startTime
                    Logger.shared.logDownload(url: urlString, success: false, error: error, duration: duration)
                    continuation.resume(throwing: error)
                }
            }
            
            downloadTask.resume()
        }
    }
}
