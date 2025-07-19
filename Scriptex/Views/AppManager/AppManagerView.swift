import SwiftUI

struct AppManagerView: View {
    @State private var isInstallingVSCode = false
    @State private var isInstallingAnyDesk = false
    @State private var vsCodeStatus = ""
    @State private var anyDeskStatus = ""
    @State private var isLaunchingVSCode = false
    @State private var isQuittingVSCode = false
    @State private var isDeletingVSCode = false
    @State private var isLaunchingAnyDesk = false
    @State private var isQuittingAnyDesk = false
    @State private var isDeletingAnyDesk = false
    
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
                        
                        HStack(spacing: 8) {
                            // Install Button
                            Button(action: {
                                installVSCode()
                            }) {
                                HStack(spacing: 4) {
                                    if isInstallingVSCode {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                    } else {
                                        Image(systemName: "arrow.down.circle")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    Text(isInstallingVSCode ? "Installing" : "Install")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isInstallingVSCode ? Color.gray : AppColors.primaryAccent)
                                .cornerRadius(4)
                            }
                            .disabled(isInstallingVSCode)
                            
                            // Launch Button
                            Button(action: {
                                launchApp("Visual Studio Code")
                            }) {
                                HStack(spacing: 4) {
                                    if isLaunchingVSCode {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                    } else {
                                        Image(systemName: "play.circle")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    Text(isLaunchingVSCode ? "Launching" : "Run")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isLaunchingVSCode ? Color.gray : Color.green)
                                .cornerRadius(4)
                            }
                            .disabled(isLaunchingVSCode)
                            
                            // Quit Button
                            Button(action: {
                                quitApp("Visual Studio Code")
                            }) {
                                HStack(spacing: 4) {
                                    if isQuittingVSCode {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                    } else {
                                        Image(systemName: "stop.circle")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    Text(isQuittingVSCode ? "Quitting" : "Quit")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isQuittingVSCode ? Color.gray : Color.orange)
                                .cornerRadius(4)
                            }
                            .disabled(isQuittingVSCode)
                            
                            // Delete Button
                            Button(action: {
                                deleteApp("Visual Studio Code")
                            }) {
                                HStack(spacing: 4) {
                                    if isDeletingVSCode {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                    } else {
                                        Image(systemName: "trash.circle")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    Text(isDeletingVSCode ? "Deleting" : "Delete")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isDeletingVSCode ? Color.gray : Color.red)
                                .cornerRadius(4)
                            }
                            .disabled(isDeletingVSCode)
                        }
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
                        
                        HStack(spacing: 8) {
                            // Install Button
                            Button(action: {
                                installAnyDesk()
                            }) {
                                HStack(spacing: 4) {
                                    if isInstallingAnyDesk {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                    } else {
                                        Image(systemName: "arrow.down.circle")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    Text(isInstallingAnyDesk ? "Installing" : "Install")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isInstallingAnyDesk ? Color.gray : AppColors.secondaryAccent)
                                .cornerRadius(4)
                            }
                            .disabled(isInstallingAnyDesk)
                            
                            // Launch Button
                            Button(action: {
                                launchApp("AnyDesk")
                            }) {
                                HStack(spacing: 4) {
                                    if isLaunchingAnyDesk {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                    } else {
                                        Image(systemName: "play.circle")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    Text(isLaunchingAnyDesk ? "Launching" : "Run")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isLaunchingAnyDesk ? Color.gray : Color.green)
                                .cornerRadius(4)
                            }
                            .disabled(isLaunchingAnyDesk)
                            
                            // Quit Button
                            Button(action: {
                                quitApp("AnyDesk")
                            }) {
                                HStack(spacing: 4) {
                                    if isQuittingAnyDesk {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                    } else {
                                        Image(systemName: "stop.circle")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    Text(isQuittingAnyDesk ? "Quitting" : "Quit")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isQuittingAnyDesk ? Color.gray : Color.orange)
                                .cornerRadius(4)
                            }
                            .disabled(isQuittingAnyDesk)
                            
                            // Delete Button
                            Button(action: {
                                deleteApp("AnyDesk")
                            }) {
                                HStack(spacing: 4) {
                                    if isDeletingAnyDesk {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                    } else {
                                        Image(systemName: "trash.circle")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    Text(isDeletingAnyDesk ? "Deleting" : "Delete")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isDeletingAnyDesk ? Color.gray : Color.red)
                                .cornerRadius(4)
                            }
                            .disabled(isDeletingAnyDesk)
                        }
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
    
    private func launchApp(_ appName: String) {
        Logger.shared.logUIEvent("Launch \(appName) button tapped", view: "AppManagerView")
        
        if appName == "Visual Studio Code" {
            isLaunchingVSCode = true
        } else if appName == "AnyDesk" {
            isLaunchingAnyDesk = true
        }
        
        Task {
            do {
                Logger.shared.info("Launching app: \(appName)", category: "AppManagement")
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/app_manager.sh"
                let result = try await ExecutionService.executeScript(at: [scriptPath, "launch", appName])
                
                await MainActor.run {
                    if appName == "Visual Studio Code" {
                        isLaunchingVSCode = false
                        if result.contains("✅") {
                            vsCodeStatus = "✅ \(appName) launched successfully!"
                        } else if result.contains("not be installed") {
                            vsCodeStatus = "⚠️ \(appName) is not installed"
                        } else {
                            vsCodeStatus = "❌ Failed to launch \(appName)"
                        }
                    } else if appName == "AnyDesk" {
                        isLaunchingAnyDesk = false
                        if result.contains("✅") {
                            anyDeskStatus = "✅ \(appName) launched successfully!"
                        } else if result.contains("not be installed") {
                            anyDeskStatus = "⚠️ \(appName) is not installed"
                        } else {
                            anyDeskStatus = "❌ Failed to launch \(appName)"
                        }
                    }
                }
                
                Logger.shared.logAppOperation(appName: appName, operation: "launch", success: result.contains("✅"))
            } catch {
                Logger.shared.error("Failed to launch \(appName): \(error.localizedDescription)", category: "AppManagement")
                await MainActor.run {
                    if appName == "Visual Studio Code" {
                        isLaunchingVSCode = false
                        vsCodeStatus = "❌ Error launching \(appName): \(error.localizedDescription)"
                    } else if appName == "AnyDesk" {
                        isLaunchingAnyDesk = false
                        anyDeskStatus = "❌ Error launching \(appName): \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func quitApp(_ appName: String) {
        Logger.shared.logUIEvent("Quit \(appName) button tapped", view: "AppManagerView")
        
        if appName == "Visual Studio Code" {
            isQuittingVSCode = true
        } else if appName == "AnyDesk" {
            isQuittingAnyDesk = true
        }
        
        Task {
            do {
                Logger.shared.info("Quitting app: \(appName)", category: "AppManagement")
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/app_manager.sh"
                let result = try await ExecutionService.executeScript(at: [scriptPath, "quit", appName])
                
                await MainActor.run {
                    if appName == "Visual Studio Code" {
                        isQuittingVSCode = false
                        if result.contains("✅") {
                            vsCodeStatus = "✅ \(appName) quit successfully!"
                        } else if result.contains("not be running") {
                            vsCodeStatus = "⚠️ \(appName) is not currently running"
                        } else {
                            vsCodeStatus = "❌ Failed to quit \(appName)"
                        }
                    } else if appName == "AnyDesk" {
                        isQuittingAnyDesk = false
                        if result.contains("✅") {
                            anyDeskStatus = "✅ \(appName) quit successfully!"
                        } else if result.contains("not be running") {
                            anyDeskStatus = "⚠️ \(appName) is not currently running"
                        } else {
                            anyDeskStatus = "❌ Failed to quit \(appName)"
                        }
                    }
                }
                
                Logger.shared.logAppOperation(appName: appName, operation: "quit", success: result.contains("✅"))
            } catch {
                Logger.shared.error("Failed to quit \(appName): \(error.localizedDescription)", category: "AppManagement")
                await MainActor.run {
                    if appName == "Visual Studio Code" {
                        isQuittingVSCode = false
                        vsCodeStatus = "❌ Error quitting \(appName): \(error.localizedDescription)"
                    } else if appName == "AnyDesk" {
                        isQuittingAnyDesk = false
                        anyDeskStatus = "❌ Error quitting \(appName): \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func deleteApp(_ appName: String) {
        Logger.shared.logUIEvent("Delete \(appName) button tapped", view: "AppManagerView")
        
        if appName == "Visual Studio Code" {
            isDeletingVSCode = true
        } else if appName == "AnyDesk" {
            isDeletingAnyDesk = true
        }
        
        Task {
            do {
                Logger.shared.info("Deleting app: \(appName)", category: "AppManagement")
                let scriptPath = "/Users/sachinkumar/Desktop/scripts/app_manager.sh"
                let result = try await ExecutionService.executeScript(at: ["bash", "-c", "echo 'y' | \(scriptPath) delete \(appName)"])
                
                await MainActor.run {
                    if appName == "Visual Studio Code" {
                        isDeletingVSCode = false
                        if result.contains("✅") {
                            vsCodeStatus = "✅ \(appName) deleted successfully!"
                        } else if result.contains("not found") {
                            vsCodeStatus = "⚠️ \(appName) is not installed"
                        } else {
                            vsCodeStatus = "❌ Failed to delete \(appName)"
                        }
                    } else if appName == "AnyDesk" {
                        isDeletingAnyDesk = false
                        if result.contains("✅") {
                            anyDeskStatus = "✅ \(appName) deleted successfully!"
                        } else if result.contains("not found") {
                            anyDeskStatus = "⚠️ \(appName) is not installed"
                        } else {
                            anyDeskStatus = "❌ Failed to delete \(appName)"
                        }
                    }
                }
                
                Logger.shared.logAppOperation(appName: appName, operation: "delete", success: result.contains("✅"))
            } catch {
                Logger.shared.error("Failed to delete \(appName): \(error.localizedDescription)", category: "AppManagement")
                await MainActor.run {
                    if appName == "Visual Studio Code" {
                        isDeletingVSCode = false
                        vsCodeStatus = "❌ Error deleting \(appName): \(error.localizedDescription)"
                    } else if appName == "AnyDesk" {
                        isDeletingAnyDesk = false
                        anyDeskStatus = "❌ Error deleting \(appName): \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
