import SwiftUI
import UniformTypeIdentifiers
import Foundation

// MARK: - AppInfo
struct AppInfo: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let displayName: String
    let description: String
    let downloadURL: String?
    let fileExtension: String?
    let installScript: String?
    let category: String
    let version: String?
    let developer: String?
    let iconName: String?
    let isInstalled: Bool
    let isStarred: Bool
    
    init(
        id: String,
        name: String,
        displayName: String,
        description: String,
        downloadURL: String? = nil,
        fileExtension: String? = nil,
        installScript: String? = nil,
        category: String = "General",
        version: String? = nil,
        developer: String? = nil,
        iconName: String? = nil,
        isInstalled: Bool = false,
        isStarred: Bool = false
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.description = description
        self.downloadURL = downloadURL
        self.fileExtension = fileExtension
        self.installScript = installScript
        self.category = category
        self.version = version
        self.developer = developer
        self.iconName = iconName
        self.isInstalled = isInstalled
        self.isStarred = isStarred
    }
    
    // Custom decoding to handle missing fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        displayName = try container.decode(String.self, forKey: .displayName)
        description = try container.decode(String.self, forKey: .description)
        downloadURL = try container.decodeIfPresent(String.self, forKey: .downloadURL)
        fileExtension = try container.decodeIfPresent(String.self, forKey: .fileExtension)
        installScript = try container.decodeIfPresent(String.self, forKey: .installScript)
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "General"
        version = try container.decodeIfPresent(String.self, forKey: .version)
        developer = try container.decodeIfPresent(String.self, forKey: .developer)
        iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
        isInstalled = try container.decodeIfPresent(Bool.self, forKey: .isInstalled) ?? false
        isStarred = try container.decodeIfPresent(Bool.self, forKey: .isStarred) ?? false
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, displayName, description, downloadURL, fileExtension
        case installScript, category, version, developer, iconName, isInstalled, isStarred
    }
}

// MARK: - AppCollection
struct AppCollection: Codable {
    let version: String
    let lastUpdated: String
    let apps: [AppInfo]
    
    init(apps: [AppInfo]) {
        self.version = "1.0"
        self.lastUpdated = ISO8601DateFormatter().string(from: Date())
        self.apps = apps
    }
}

// MARK: - AppManager Service
class AppManager: ObservableObject {
    @Published var apps: [AppInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let appsFilePath = "/Users/sachinkumar/Desktop/Scriptex/apps.json"
    private let fileManager = FileManager.default
    
    init() {
        loadApps()
    }
    
    // MARK: - Load Apps
    func loadApps() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedApps = try await loadAppsFromFile()
                await MainActor.run {
                    self.apps = loadedApps
                    self.isLoading = false
                    Logger.shared.info("Loaded \(loadedApps.count) apps from JSON", category: "AppManager")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load apps: \(error.localizedDescription)"
                    self.isLoading = false
                    Logger.shared.error("Failed to load apps: \(error.localizedDescription)", category: "AppManager")
                }
            }
        }
    }
    
    private func loadAppsFromFile() async throws -> [AppInfo] {
        guard fileManager.fileExists(atPath: appsFilePath) else {
            // Create default apps file if it doesn't exist
            let defaultApps = createDefaultApps()
            try await saveAppsToFile(defaultApps)
            return defaultApps
        }
        
        let data = try Data(contentsOf: URL(fileURLWithPath: appsFilePath))
        let appCollection = try JSONDecoder().decode(AppCollection.self, from: data)
        return appCollection.apps
    }
    
    // MARK: - Save Apps
    func saveApps() async throws {
        try await saveAppsToFile(apps)
        Logger.shared.info("Saved \(apps.count) apps to JSON", category: "AppManager")
    }
    
    private func saveAppsToFile(_ apps: [AppInfo]) async throws {
        let appCollection = AppCollection(apps: apps)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(appCollection)
        try data.write(to: URL(fileURLWithPath: appsFilePath))
    }
    
    // MARK: - Import/Export
    func importApps(from filePath: String) async throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
        
        // Try to decode as AppCollection first
        do {
            let appCollection = try JSONDecoder().decode(AppCollection.self, from: data)
            await MainActor.run {
                self.apps = appCollection.apps
                Logger.shared.info("Imported \(appCollection.apps.count) apps from \(filePath) (AppCollection format)", category: "AppManager")
            }
        } catch {
            // If that fails, try to decode as a simple array or direct object
            do {
                // Try as direct apps array
                let appsArray = try JSONDecoder().decode([AppInfo].self, from: data)
                await MainActor.run {
                    self.apps = appsArray
                    Logger.shared.info("Imported \(appsArray.count) apps from \(filePath) (Array format)", category: "AppManager")
                }
            } catch {
                // Try as object with "apps" key
                let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let appsData = jsonObject?["apps"] as? [[String: Any]] {
                    let appsJsonData = try JSONSerialization.data(withJSONObject: appsData)
                    let appsArray = try JSONDecoder().decode([AppInfo].self, from: appsJsonData)
                    await MainActor.run {
                        self.apps = appsArray
                        Logger.shared.info("Imported \(appsArray.count) apps from \(filePath) (Object format)", category: "AppManager")
                    }
                } else {
                    throw NSError(domain: "ImportError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported JSON format. Expected AppCollection, array of apps, or object with 'apps' array."])
                }
            }
        }
        
        try await saveApps()
    }
    
    func exportApps(to filePath: String) async throws {
        let appCollection = AppCollection(apps: apps)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(appCollection)
        try data.write(to: URL(fileURLWithPath: filePath))
        Logger.shared.info("Exported \(apps.count) apps to \(filePath)", category: "AppManager")
    }
    
    // MARK: - App Operations
    func updateAppInstallStatus(_ appId: String, isInstalled: Bool) {
        if let index = apps.firstIndex(where: { $0.id == appId }) {
            apps[index] = AppInfo(
                id: apps[index].id,
                name: apps[index].name,
                displayName: apps[index].displayName,
                description: apps[index].description,
                downloadURL: apps[index].downloadURL,
                fileExtension: apps[index].fileExtension,
                installScript: apps[index].installScript,
                category: apps[index].category,
                version: apps[index].version,
                developer: apps[index].developer,
                iconName: apps[index].iconName,
                isInstalled: isInstalled,
                isStarred: apps[index].isStarred
            )
            
            Task {
                try await saveApps()
            }
        }
    }
    
    func addApp(_ app: AppInfo) {
        apps.append(app)
        Task {
            try await saveApps()
        }
    }
    
    func removeApp(_ appId: String) {
        apps.removeAll { $0.id == appId }
        Task {
            try await saveApps()
        }
    }
    
    func toggleStar(_ appId: String) {
        if let index = apps.firstIndex(where: { $0.id == appId }) {
            apps[index] = AppInfo(
                id: apps[index].id,
                name: apps[index].name,
                displayName: apps[index].displayName,
                description: apps[index].description,
                downloadURL: apps[index].downloadURL,
                fileExtension: apps[index].fileExtension,
                installScript: apps[index].installScript,
                category: apps[index].category,
                version: apps[index].version,
                developer: apps[index].developer,
                iconName: apps[index].iconName,
                isInstalled: apps[index].isInstalled,
                isStarred: !apps[index].isStarred
            )
            
            Task {
                try await saveApps()
            }
        }
    }
    
    // MARK: - Default Apps
    private func createDefaultApps() -> [AppInfo] {
        return [
            AppInfo(
                id: "vscode",
                name: "Visual Studio Code",
                displayName: "Visual Studio Code",
                description: "Microsoft's lightweight code editor",
                downloadURL: "https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal",
                fileExtension: "zip",
                installScript: "/Users/sachinkumar/Desktop/TerminalScripts All Platforms/Mac/universal_installer.sh",
                category: "Development",
                version: "Latest",
                developer: "Microsoft",
                iconName: "chevron.left.forwardslash.chevron.right"
            ),
            AppInfo(
                id: "anydesk",
                name: "AnyDesk",
                displayName: "AnyDesk",
                description: "Remote desktop access software",
                downloadURL: "https://download.anydesk.com/anydesk.dmg",
                fileExtension: "dmg",
                installScript: "/Users/sachinkumar/Desktop/TerminalScripts All Platforms/Mac/universal_installer.sh",
                category: "Utilities",
                version: "Latest",
                developer: "AnyDesk Software GmbH",
                iconName: "display"
            )
        ]
    }
}

struct AppManagerView: View {
    @StateObject private var appManager = AppManager()
    @State private var operationStates: [String: AppOperationState] = [:]
    @State private var showingImportPicker = false
    @State private var showingExportPicker = false
    @State private var statusMessages: [String: String] = [:]
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showOnlyStarred = false
    
    private var categories: [String] {
        let allCategories = Set(appManager.apps.map { $0.category })
        return ["All"] + Array(allCategories).sorted()
    }
    
    private var filteredApps: [AppInfo] {
        appManager.apps.filter { app in
            let matchesSearch = searchText.isEmpty || 
                app.displayName.localizedCaseInsensitiveContains(searchText) ||
                app.description.localizedCaseInsensitiveContains(searchText) ||
                app.developer?.localizedCaseInsensitiveContains(searchText) == true
            
            let matchesCategory = selectedCategory == "All" || app.category == selectedCategory
            let matchesStarFilter = !showOnlyStarred || app.isStarred
            
            return matchesSearch && matchesCategory && matchesStarFilter
        }.sorted { first, second in
            // Sort by: starred first, then installed, then alphabetically
            if first.isStarred != second.isStarred {
                return first.isStarred && !second.isStarred
            }
            if first.isInstalled != second.isInstalled {
                return first.isInstalled && !second.isInstalled
            }
            return first.displayName < second.displayName
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
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
                
                // Import/Export Buttons
                HStack(spacing: 12) {
                    Button(action: { showingImportPicker = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 14, weight: .medium))
                            Text("Import Apps")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(6)
                    }
                    
                    Button(action: { showingExportPicker = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .medium))
                            Text("Export Apps")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // Search and Filters
            VStack(alignment: .leading, spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search apps...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Filter Controls
                HStack(spacing: 16) {
                    // Category Filter
                    HStack(spacing: 8) {
                        Text("Category:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(minWidth: 120)
                    }
                    
                    // Starred Filter
                    Toggle(isOn: $showOnlyStarred) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                            Text("Starred only")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    
                    Spacer()
                    
                    // Results count
                    Text("\(filteredApps.count) apps")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            
            // Import/Export Status Messages
            if let importMessage = statusMessages["import"] {
                Text(importMessage)
                    .font(.system(size: 14))
                    .foregroundColor(importMessage.contains("✅") ? .green : .red)
                    .padding(.horizontal, 24)
            }
            
            if let exportMessage = statusMessages["export"] {
                Text(exportMessage)
                    .font(.system(size: 14))
                    .foregroundColor(exportMessage.contains("✅") ? .green : .red)
                    .padding(.horizontal, 24)
            }
            
            // Error Message
            if let errorMessage = appManager.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
            }
            
            // Loading Indicator
            if appManager.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading apps...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
            }
            
            // Apps List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if filteredApps.isEmpty && !searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No apps found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Try adjusting your search or filters")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        ForEach(filteredApps) { app in
                            AppCardView(
                                app: app,
                                operationState: operationStates[app.id] ?? AppOperationState(),
                                statusMessage: statusMessages[app.id] ?? "",
                                onInstall: { installApp(app) },
                                onLaunch: { launchApp(app) },
                                onQuit: { quitApp(app) },
                                onDelete: { deleteApp(app) },
                                onToggleStar: { appManager.toggleStar(app.id) }
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [UTType.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .fileExporter(
            isPresented: $showingExportPicker,
            document: AppJSONDocument(apps: appManager.apps),
            contentType: UTType.json,
            defaultFilename: "apps.json"
        ) { result in
            handleExport(result)
        }
        .onAppear {
            initializeOperationStates()
        }
        .onChange(of: appManager.apps) { _ in
            initializeOperationStates()
        }
    }
    
    private func initializeOperationStates() {
        for app in appManager.apps {
            if operationStates[app.id] == nil {
                operationStates[app.id] = AppOperationState()
            }
        }
    }
    
    // MARK: - App Operations
    
    private func installApp(_ app: AppInfo) {
        Logger.shared.logUIEvent("Install \(app.name) button tapped", view: "AppManagerView")
        
        operationStates[app.id]?.isInstalling = true
        statusMessages[app.id] = "Downloading \(app.name)..."
        
        Task {
            do {
                Logger.shared.info("Starting \(app.name) installation", category: "AppInstallation")
                
                if let downloadURL = app.downloadURL {
                    await MainActor.run {
                        statusMessages[app.id] = "Downloading \(app.name)..."
                    }
                    
                    let fileName = "\(app.id).\(app.fileExtension ?? "dmg")"
                    let downloadedPath = try await downloadFile(from: downloadURL, fileName: fileName)
                    
                    await MainActor.run {
                        statusMessages[app.id] = "Installing \(app.name)..."
                    }
                    
                    let scriptPath = app.installScript ?? "/Users/sachinkumar/Desktop/TerminalScripts All Platforms/Mac/universal_installer.sh"
                    let result = try await ExecutionService.executeScript(at: [scriptPath, "-f", downloadedPath])
                    
                    await MainActor.run {
                        operationStates[app.id]?.isInstalling = false
                        if result.contains("completed successfully") {
                            statusMessages[app.id] = "✅ \(app.name) installed successfully!"
                            appManager.updateAppInstallStatus(app.id, isInstalled: true)
                            Logger.shared.logAppInstallation(appName: app.name, success: true)
                        } else {
                            statusMessages[app.id] = "❌ Installation failed. Check console for details."
                            Logger.shared.logAppInstallation(appName: app.name, success: false)
                        }
                    }
                } else {
                    await MainActor.run {
                        operationStates[app.id]?.isInstalling = false
                        statusMessages[app.id] = "⚠️ No download URL specified for \(app.name)"
                    }
                }
            } catch {
                Logger.shared.logAppInstallation(appName: app.name, success: false, error: error)
                await MainActor.run {
                    operationStates[app.id]?.isInstalling = false
                    statusMessages[app.id] = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func launchApp(_ app: AppInfo) {
        Logger.shared.logUIEvent("Launch \(app.name) button tapped", view: "AppManagerView")
        
        operationStates[app.id]?.isLaunching = true
        
        Task {
            do {
                Logger.shared.info("Launching app: \(app.name)", category: "AppManagement")
                let scriptPath = "/Users/sachinkumar/Desktop/TerminalScripts All Platforms/Mac/app_manager.sh"
                let result = try await ExecutionService.executeScript(at: [scriptPath, "launch", app.name])
                
                await MainActor.run {
                    operationStates[app.id]?.isLaunching = false
                    if result.contains("✅") {
                        statusMessages[app.id] = "✅ \(app.name) launched successfully!"
                    } else if result.contains("not be installed") {
                        statusMessages[app.id] = "⚠️ \(app.name) is not installed"
                    } else {
                        statusMessages[app.id] = "❌ Failed to launch \(app.name)"
                    }
                }
                
                Logger.shared.logAppOperation(appName: app.name, operation: "launch", success: result.contains("✅"))
            } catch {
                Logger.shared.error("Failed to launch \(app.name): \(error.localizedDescription)", category: "AppManagement")
                await MainActor.run {
                    operationStates[app.id]?.isLaunching = false
                    statusMessages[app.id] = "❌ Error launching \(app.name): \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func quitApp(_ app: AppInfo) {
        Logger.shared.logUIEvent("Quit \(app.name) button tapped", view: "AppManagerView")
        
        operationStates[app.id]?.isQuitting = true
        
        Task {
            do {
                Logger.shared.info("Quitting app: \(app.name)", category: "AppManagement")
                let scriptPath = "/Users/sachinkumar/Desktop/TerminalScripts All Platforms/Mac/app_manager.sh"
                let result = try await ExecutionService.executeScript(at: [scriptPath, "quit", app.name])
                
                await MainActor.run {
                    operationStates[app.id]?.isQuitting = false
                    if result.contains("✅") {
                        statusMessages[app.id] = "✅ \(app.name) quit successfully!"
                    } else if result.contains("not be running") {
                        statusMessages[app.id] = "⚠️ \(app.name) is not currently running"
                    } else {
                        statusMessages[app.id] = "❌ Failed to quit \(app.name)"
                    }
                }
                
                Logger.shared.logAppOperation(appName: app.name, operation: "quit", success: result.contains("✅"))
            } catch {
                Logger.shared.error("Failed to quit \(app.name): \(error.localizedDescription)", category: "AppManagement")
                await MainActor.run {
                    operationStates[app.id]?.isQuitting = false
                    statusMessages[app.id] = "❌ Error quitting \(app.name): \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func deleteApp(_ app: AppInfo) {
        Logger.shared.logUIEvent("Delete \(app.name) button tapped", view: "AppManagerView")
        
        operationStates[app.id]?.isDeleting = true
        
        Task {
            do {
                Logger.shared.info("Deleting app: \(app.name)", category: "AppManagement")
                let scriptPath = "/Users/sachinkumar/Desktop/TerminalScripts All Platforms/Mac/app_manager.sh"
                let result = try await ExecutionService.executeScript(at: ["bash", "-c", "echo 'y' | \(scriptPath) delete \(app.name)"])
                
                await MainActor.run {
                    operationStates[app.id]?.isDeleting = false
                    if result.contains("✅") {
                        statusMessages[app.id] = "✅ \(app.name) deleted successfully!"
                        appManager.updateAppInstallStatus(app.id, isInstalled: false)
                    } else if result.contains("not found") {
                        statusMessages[app.id] = "⚠️ \(app.name) is not installed"
                    } else {
                        statusMessages[app.id] = "❌ Failed to delete \(app.name)"
                    }
                }
                
                Logger.shared.logAppOperation(appName: app.name, operation: "delete", success: result.contains("✅"))
            } catch {
                Logger.shared.error("Failed to delete \(app.name): \(error.localizedDescription)", category: "AppManagement")
                await MainActor.run {
                    operationStates[app.id]?.isDeleting = false
                    statusMessages[app.id] = "❌ Error deleting \(app.name): \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Import/Export Handlers
    
    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Clear any previous import status
            statusMessages.removeValue(forKey: "import")
            
            Task {
                do {
                    try await appManager.importApps(from: url.path)
                    await MainActor.run {
                        statusMessages["import"] = "✅ Apps imported successfully from \(url.lastPathComponent)!"
                        // Clear the message after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            statusMessages.removeValue(forKey: "import")
                        }
                    }
                } catch {
                    await MainActor.run {
                        statusMessages["import"] = "❌ Import failed: \(error.localizedDescription)"
                        // Clear the error message after 10 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            statusMessages.removeValue(forKey: "import")
                        }
                    }
                    Logger.shared.error("Failed to import apps from \(url.path): \(error.localizedDescription)", category: "AppManager")
                }
            }
            
        case .failure(let error):
            statusMessages["import"] = "❌ File selection failed: \(error.localizedDescription)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                statusMessages.removeValue(forKey: "import")
            }
            Logger.shared.error("Import file picker failed: \(error.localizedDescription)", category: "AppManager")
        }
    }
    
    private func handleExport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            // Clear any previous export status
            statusMessages.removeValue(forKey: "export")
            
            Task {
                do {
                    try await appManager.exportApps(to: url.path)
                    await MainActor.run {
                        statusMessages["export"] = "✅ Apps exported successfully to \(url.lastPathComponent)!"
                        // Clear the message after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            statusMessages.removeValue(forKey: "export")
                        }
                    }
                } catch {
                    await MainActor.run {
                        statusMessages["export"] = "❌ Export failed: \(error.localizedDescription)"
                        // Clear the error message after 10 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            statusMessages.removeValue(forKey: "export")
                        }
                    }
                    Logger.shared.error("Failed to export apps to \(url.path): \(error.localizedDescription)", category: "AppManager")
                }
            }
            
        case .failure(let error):
            statusMessages["export"] = "❌ File selection failed: \(error.localizedDescription)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                statusMessages.removeValue(forKey: "export")
            }
            Logger.shared.error("Export file picker failed: \(error.localizedDescription)", category: "AppManager")
        }
    }
    
    // MARK: - Download Helper
    
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
                    
                    if FileManager.default.fileExists(atPath: namedTempURL.path) {
                        try FileManager.default.removeItem(at: namedTempURL)
                    }
                    
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

// MARK: - AppCardView

struct AppCardView: View {
    let app: AppInfo
    @ObservedObject var operationState: AppOperationState
    let statusMessage: String
    let onInstall: () -> Void
    let onLaunch: () -> Void
    let onQuit: () -> Void
    let onDelete: () -> Void
    let onToggleStar: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        if let iconName = app.iconName {
                            Image(systemName: iconName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.primaryAccent)
                        }
                        
                        Text(app.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if app.isStarred {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                        
                        if app.isInstalled {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(app.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    if let developer = app.developer {
                        Text("by \(developer)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 8) {
                    // Star Button
                    Button(action: onToggleStar) {
                        Image(systemName: app.isStarred ? "star.fill" : "star")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(app.isStarred ? .yellow : .gray)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Install Button
                    Button(action: onInstall) {
                        HStack(spacing: 4) {
                            if operationState.isInstalling {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "arrow.down.circle")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            Text(operationState.isInstalling ? "Installing" : "Install")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(operationState.isInstalling ? Color.gray : AppColors.primaryAccent)
                        .cornerRadius(4)
                    }
                    .disabled(operationState.isInstalling)
                    
                    // Launch Button
                    Button(action: onLaunch) {
                        HStack(spacing: 4) {
                            if operationState.isLaunching {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "play.circle")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            Text(operationState.isLaunching ? "Launching" : "Run")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(operationState.isLaunching ? Color.gray : Color.green)
                        .cornerRadius(4)
                    }
                    .disabled(operationState.isLaunching)
                    
                    // Quit Button
                    Button(action: onQuit) {
                        HStack(spacing: 4) {
                            if operationState.isQuitting {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "stop.circle")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            Text(operationState.isQuitting ? "Quitting" : "Quit")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(operationState.isQuitting ? Color.gray : Color.orange)
                        .cornerRadius(4)
                    }
                    .disabled(operationState.isQuitting)
                    
                    // Delete Button
                    Button(action: onDelete) {
                        HStack(spacing: 4) {
                            if operationState.isDeleting {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "trash.circle")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            Text(operationState.isDeleting ? "Deleting" : "Delete")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(operationState.isDeleting ? Color.gray : Color.red)
                        .cornerRadius(4)
                    }
                    .disabled(operationState.isDeleting)
                }
            }
            
            // Status Message
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.system(size: 14))
                    .foregroundColor(statusMessage.contains("✅") ? .green : statusMessage.contains("⚠️") ? .orange : .red)
                    .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

// MARK: - AppOperationState

class AppOperationState: ObservableObject {
    @Published var isInstalling = false
    @Published var isLaunching = false
    @Published var isQuitting = false
    @Published var isDeleting = false
}

// MARK: - AppJSONDocument

struct AppJSONDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.json]
    static var writableContentTypes: [UTType] = [.json]
    
    let apps: [AppInfo]
    
    init(apps: [AppInfo]) {
        self.apps = apps
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let appCollection = try JSONDecoder().decode(AppCollection.self, from: data)
        self.apps = appCollection.apps
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let appCollection = AppCollection(apps: apps)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(appCollection)
        return FileWrapper(regularFileWithContents: data)
    }
}
