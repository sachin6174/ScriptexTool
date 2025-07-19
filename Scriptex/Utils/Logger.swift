import Foundation
import os
import Darwin

// MARK: - Log Level
enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }
}

// MARK: - Logger
class Logger {
    static let shared = Logger()
    
    private let logFilePath: String
    private let fileManager = FileManager.default
    private let dateFormatter: DateFormatter
    private let queue = DispatchQueue(label: "com.scriptex.logger", qos: .utility)
    private var sessionId: String
    
    private init() {
        // Generate unique session ID
        sessionId = UUID().uuidString.prefix(8).description
        
        // Setup log file path
        let logDirectory = "/Users/sachinkumar/Desktop/logs"
        logFilePath = "\(logDirectory)/log.txt"
        
        // Setup date formatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone.current
        
        // Create logs directory if it doesn't exist
        createLogDirectoryIfNeeded()
        
        // Defer startup logging to avoid initialization issues
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Log startup with session info
            let startupMessage = "Logger initialized | Session: \(self.sessionId) | App Version: \(self.getProcessInfo().version)"
            self.log(.info, message: startupMessage, category: "System")
            
            // Log system environment
            self.logSystemEnvironment()
        }
    }
    
    private func createLogDirectoryIfNeeded() {
        guard !logFilePath.isEmpty else {
            print("Logger: Invalid log file path")
            return
        }
        
        let logDirectory = URL(fileURLWithPath: logFilePath).deletingLastPathComponent().path
        
        guard !logDirectory.isEmpty else {
            print("Logger: Invalid log directory path")
            return
        }
        
        if !fileManager.fileExists(atPath: logDirectory) {
            do {
                try fileManager.createDirectory(atPath: logDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Logger: Created log directory at \(logDirectory)")
            } catch {
                print("Logger: Failed to create log directory: \(error)")
            }
        }
    }
    
    // MARK: - Public Logging Methods
    
    func debug(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message: message, category: category, file: file, function: function, line: line)
    }
    
    func info(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message: message, category: category, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message: message, category: category, file: file, function: function, line: line)
    }
    
    func error(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message: message, category: category, file: file, function: function, line: line)
    }
    
    func critical(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(.critical, message: message, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Core Logging Method
    
    private func log(_ level: LogLevel, message: String, category: String, file: String = #file, function: String = #function, line: Int = #line) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let timestamp = self.dateFormatter.string(from: Date())
            let fileName = URL(fileURLWithPath: file).lastPathComponent
            let formattedMessage = self.formatLogMessage(
                timestamp: timestamp,
                level: level,
                category: category,
                message: message,
                file: fileName,
                function: function,
                line: line
            )
            
            // Write to file
            self.writeToFile(formattedMessage)
            
            // Also print to console in debug builds
            #if DEBUG
            print(formattedMessage)
            #endif
        }
    }
    
    private func formatLogMessage(timestamp: String, level: LogLevel, category: String, message: String, file: String, function: String, line: Int) -> String {
        let threadInfo = getThreadInfo()
        let memoryInfo = getMemoryInfo()
        let processInfo = getProcessInfo()
        
        let debugInfo = "\(file):\(function):\(line)"
        let threadDetails = "Thread: \(threadInfo.name) [\(threadInfo.id)] \(threadInfo.isMain ? "(MAIN)" : "(BG)")"
        let systemInfo = "PID: \(processInfo.pid) | Memory: \(memoryInfo.used)MB/\(memoryInfo.total)MB | Queue: \(threadInfo.queueLabel)"
        let sessionInfo = "Session: \(sessionId)"
        
        return "[\(timestamp)] \(level.emoji) \(level.rawValue) [\(category)] \(message)\n" +
               "   ↳ 📍 \(debugInfo)\n" +
               "   ↳ 🧵 \(threadDetails)\n" +
               "   ↳ 💻 \(systemInfo)\n" +
               "   ↳ 🎯 \(sessionInfo)"
    }
    
    private func writeToFile(_ message: String) {
        guard !logFilePath.isEmpty else {
            print("Logger: Cannot write to file - invalid path")
            return
        }
        
        let logEntry = message + "\n"
        
        guard let data = logEntry.data(using: .utf8) else {
            print("Logger: Failed to encode log message")
            return
        }
        
        do {
            if fileManager.fileExists(atPath: logFilePath) {
                // Append to existing file
                let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: logFilePath))
                defer { try? fileHandle.close() }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            } else {
                // Create new file
                try data.write(to: URL(fileURLWithPath: logFilePath))
            }
        } catch {
            print("Logger: Failed to write to log file: \(error)")
        }
    }
    
    // MARK: - Thread and System Info Methods
    
    private func getThreadInfo() -> (name: String, id: String, isMain: Bool, queueLabel: String) {
        let isMainThread = Thread.isMainThread
        let threadName = Thread.current.name ?? "Unknown"
        let threadId = String(format: "%p", Thread.current)
        
        // Get current queue label
        var queueLabel = "Unknown"
        if let label = String(validatingUTF8: __dispatch_queue_get_label(nil)) {
            queueLabel = label.isEmpty ? "com.apple.main-thread" : label
        }
        
        return (
            name: threadName.isEmpty ? "Thread-\(threadId.suffix(8))" : threadName,
            id: threadId,
            isMain: isMainThread,
            queueLabel: queueLabel
        )
    }
    
    private func getMemoryInfo() -> (used: Int, total: Int) {
        let processInfo = ProcessInfo.processInfo
        let physicalMemory = processInfo.physicalMemory
        
        // Get current memory usage
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        let usedMemory = result == KERN_SUCCESS ? Int(info.resident_size) / (1024 * 1024) : 0
        let totalMemory = Int(physicalMemory) / (1024 * 1024)
        
        return (used: usedMemory, total: totalMemory)
    }
    
    private func getProcessInfo() -> (pid: Int32, name: String, version: String) {
        let processInfo = ProcessInfo.processInfo
        let version: String
        
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            version = bundleVersion
        } else {
            version = "Unknown"
        }
        
        return (
            pid: processInfo.processIdentifier,
            name: processInfo.processName,
            version: version
        )
    }
    
    // MARK: - Enhanced Logging Methods
    
    func logPerformance<T>(_ operation: String, category: String = "Performance", file: String = #file, function: String = #function, line: Int = #line, block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let startMemory = getMemoryInfo().used
        
        log(.debug, message: "Starting \(operation)", category: category, file: file, function: function, line: line)
        
        let result = try block()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let endMemory = getMemoryInfo().used
        let duration = (endTime - startTime) * 1000 // Convert to milliseconds
        let memoryDelta = endMemory - startMemory
        
        let performanceMessage = "Completed \(operation) - Duration: \(String(format: "%.2f", duration))ms | Memory Δ: \(memoryDelta > 0 ? "+" : "")\(memoryDelta)MB"
        log(.info, message: performanceMessage, category: category, file: file, function: function, line: line)
        
        return result
    }
    
    private func logSystemEnvironment() {
        let processInfo = ProcessInfo.processInfo
        let systemVersion = processInfo.operatingSystemVersionString
        let processorCount = processInfo.processorCount
        let physicalMemoryMB = Int(processInfo.physicalMemory / (1024 * 1024))
        
        let envMessage = "System Environment | OS: \(systemVersion) | CPUs: \(processorCount) | RAM: \(physicalMemoryMB)MB"
        log(.info, message: envMessage, category: "System")
    }
    
    func logWithStackTrace(_ level: LogLevel, message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        let stackTrace = Thread.callStackSymbols.prefix(5).joined(separator: "\n   ")
        let messageWithStack = "\(message)\n📚 Stack Trace (top 5):\n   \(stackTrace)"
        log(level, message: messageWithStack, category: category, file: file, function: function, line: line)
    }
    
    func logObjectLifecycle(_ object: AnyObject, event: String, category: String = "Lifecycle", file: String = #file, function: String = #function, line: Int = #line) {
        let objectId = String(format: "%p", unsafeBitCast(object, to: Int.self))
        let objectType = String(describing: type(of: object))
        let message = "\(objectType) [\(objectId)] - \(event)"
        log(.debug, message: message, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Utility Methods
    
    func clearLogs() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let fileSize = self.getLogFileSize()
            
            do {
                try "".write(toFile: self.logFilePath, atomically: true, encoding: .utf8)
                self.log(.info, message: "Log file cleared (was \(fileSize / 1024)KB)", category: "System")
            } catch {
                self.log(.error, message: "Failed to clear log file: \(error)", category: "System")
            }
        }
    }
    
    func getLogFileSize() -> Int64 {
        guard let attributes = try? fileManager.attributesOfItem(atPath: logFilePath),
              let fileSize = attributes[.size] as? Int64 else {
            return 0
        }
        return fileSize
    }
    
    func rotateLogs(maxSizeInMB: Int = 10) {
        let maxSizeInBytes = Int64(maxSizeInMB * 1024 * 1024)
        
        if getLogFileSize() > maxSizeInBytes {
            queue.async { [weak self] in
                guard let self = self else { return }
                
                let backupPath = self.logFilePath.replacingOccurrences(of: ".txt", with: "_backup.txt")
                
                do {
                    // Remove old backup if exists
                    if self.fileManager.fileExists(atPath: backupPath) {
                        try self.fileManager.removeItem(atPath: backupPath)
                    }
                    
                    // Move current log to backup
                    try self.fileManager.moveItem(atPath: self.logFilePath, toPath: backupPath)
                    
                    // Create new log file
                    self.fileManager.createFile(atPath: self.logFilePath, contents: nil, attributes: nil)
                    
                    self.log(.info, message: "Log file rotated. Backup created at: \(backupPath)", category: "System")
                } catch {
                    self.log(.error, message: "Failed to rotate log file: \(error)", category: "System")
                }
            }
        }
    }
}

// MARK: - Static Convenience Methods

extension Logger {
    // Static wrapper for logScriptExecution to match expected signature
    static func logScriptExecution(path: String, success: Bool, output: String?) {
        shared.logScriptExecution(path: path, success: success, output: output)
    }
}

// MARK: - Convenience Extensions

extension Logger {
    // Script execution logging
    func logScriptExecution(path: String, success: Bool, output: String? = nil, duration: TimeInterval? = nil, exitCode: Int32? = nil) {
        var message = "Script execution at \(path) - Success: \(success)"
        
        if let duration = duration {
            message += " | Duration: \(String(format: "%.2f", duration * 1000))ms"
        }
        
        if let exitCode = exitCode {
            message += " | Exit Code: \(exitCode)"
        }
        
        if let output = output {
            message += "\n📄 Output (\(output.count) chars):\n\(output.prefix(500))\(output.count > 500 ? "... (truncated)" : "")"
        }
        
        log(success ? .info : .error, message: message, category: "ScriptExecution")
    }
    
    // App installation logging
    func logAppInstallation(appName: String, success: Bool, error: Error? = nil, installPath: String? = nil, fileSize: Int64? = nil) {
        var message = "\(appName) installation - Success: \(success)"
        
        if let installPath = installPath {
            message += " | Path: \(installPath)"
        }
        
        if let fileSize = fileSize {
            let fileSizeMB = Double(fileSize) / (1024 * 1024)
            message += " | Size: \(String(format: "%.1f", fileSizeMB))MB"
        }
        
        if let error = error {
            message += "\n❌ Error Details: \(error.localizedDescription)"
            if let nsError = error as NSError? {
                message += "\n   Domain: \(nsError.domain) | Code: \(nsError.code)"
            }
        }
        
        log(success ? .info : .error, message: message, category: "AppInstallation")
    }
    
    // Network/Download logging
    func logDownload(url: String, success: Bool, filePath: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, fileSize: Int64? = nil, statusCode: Int? = nil) {
        var message = "Download from \(url) - Success: \(success)"
        
        if let statusCode = statusCode {
            message += " | HTTP: \(statusCode)"
        }
        
        if let duration = duration {
            message += " | Duration: \(String(format: "%.2f", duration))s"
        }
        
        if let fileSize = fileSize {
            let fileSizeMB = Double(fileSize) / (1024 * 1024)
            message += " | Size: \(String(format: "%.1f", fileSizeMB))MB"
            
            if let duration = duration, duration > 0 {
                let speedMBps = fileSizeMB / duration
                message += " | Speed: \(String(format: "%.1f", speedMBps))MB/s"
            }
        }
        
        if let filePath = filePath {
            message += "\n💾 Saved to: \(filePath)"
        }
        
        if let error = error {
            message += "\n❌ Error: \(error.localizedDescription)"
        }
        
        log(success ? .info : .error, message: message, category: "Download")
    }
    
    // System info logging
    func logSystemInfo(operation: String, success: Bool, details: String? = nil) {
        var message = "System info \(operation) - Success: \(success)"
        if let details = details {
            message += "\nDetails: \(details)"
        }
        log(success ? .info : .warning, message: message, category: "SystemInfo")
    }
    
    // Async operation logging
    func logAsyncOperation(_ operation: String, taskId: String? = nil, category: String = "Async", file: String = #file, function: String = #function, line: Int = #line) {
        let id = taskId ?? UUID().uuidString.prefix(8).description
        let message = "Async operation started: \(operation) [ID: \(id)]"
        log(.debug, message: message, category: category, file: file, function: function, line: line)
    }
    
    func logAsyncCompletion(_ operation: String, taskId: String? = nil, success: Bool, result: Any? = nil, error: Error? = nil, category: String = "Async", file: String = #file, function: String = #function, line: Int = #line) {
        let id = taskId ?? "Unknown"
        var message = "Async operation completed: \(operation) [ID: \(id)] - Success: \(success)"
        
        if let result = result {
            message += "\n✅ Result: \(result)"
        }
        
        if let error = error {
            message += "\n❌ Error: \(error.localizedDescription)"
        }
        
        log(success ? .info : .error, message: message, category: category, file: file, function: function, line: line)
    }
    
    // File operation logging
    func logFileOperation(_ operation: String, path: String, success: Bool, error: Error? = nil, fileSize: Int64? = nil, category: String = "FileOps", file: String = #file, function: String = #function, line: Int = #line) {
        var message = "File \(operation): \(path) - Success: \(success)"
        
        if let fileSize = fileSize {
            let fileSizeKB = Double(fileSize) / 1024
            message += " | Size: \(String(format: "%.1f", fileSizeKB))KB"
        }
        
        if let error = error {
            message += "\n❌ Error: \(error.localizedDescription)"
        }
        
        log(success ? .info : .error, message: message, category: category, file: file, function: function, line: line)
    }
    
    // UI event logging
    func logUIEvent(_ event: String, view: String, details: [String: Any]? = nil, category: String = "UI", file: String = #file, function: String = #function, line: Int = #line) {
        var message = "UI Event: \(event) in \(view)"
        
        if let details = details {
            let detailsString = details.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            message += " | Details: \(detailsString)"
        }
        
        log(.debug, message: message, category: category, file: file, function: function, line: line)
    }
    
    // App operation logging
    func logAppOperation(appName: String, operation: String, success: Bool, error: Error? = nil, category: String = "AppManagement", file: String = #file, function: String = #function, line: Int = #line) {
        var message = "App \(operation): \(appName) - Success: \(success)"
        
        if let error = error {
            message += "\n❌ Error: \(error.localizedDescription)"
            if let nsError = error as NSError? {
                message += "\n   Domain: \(nsError.domain) | Code: \(nsError.code)"
            }
        }
        
        log(success ? .info : .error, message: message, category: category, file: file, function: function, line: line)
    }
}