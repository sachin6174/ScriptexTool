// MIT License
//
// Copyright (c) [2020-present] Alexis Bridoux
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

// MARK: - ExecutionService

/// Execute a script.
enum ExecutionService {

    // MARK: Constants

    static let programURL = URL(fileURLWithPath: "/usr/bin/env")

    // MARK: Execute

    /// Execute the script at the provided URL.
    static func executeScript(at path: [String]) async throws -> String {
        NSLog("Helper ExecutionService: Starting script execution at \(path)")
        
        let process = Process()
        process.executableURL = programURL
        process.arguments = path

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            try process.run()
            
            let result = try await Task {
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

                guard let output = String(data: outputData, encoding: .utf8) else {
                    throw ScriptexError.invalidStringConversion
                }

                return output
            }
            .value
            
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            NSLog("Helper ExecutionService: Script execution completed successfully in \(String(format: "%.2f", duration))s")
            NSLog("Helper ExecutionService: Output length: \(result.count) characters")
            
            return result
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            NSLog("Helper ExecutionService: Script execution failed after \(String(format: "%.2f", duration))s: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func executeAsyncCommand(
        at path: [String],
        completion: @escaping (_ chunk: String, _ isLast: Bool, _ pid: Int32) -> ()
    ) {
        NSLog("sachinaaa_executeAsyncCommand starting with path: \(path)")
        
        // Verify the script exists
        if !FileManager.default.fileExists(atPath: path[0]) {
            NSLog("sachinaaa_executeAsyncCommand ERROR: File doesn't exist at \(path[0])")
            DispatchQueue.main.async {
                completion("Error: File doesn't exist at \(path[0])", true, 0)
            }
            return
        }
        
        // Make sure the script is executable
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: path[0])
        
        let process = Process()
        process.executableURL = programURL
        process.arguments = path
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        let handle = outputPipe.fileHandleForReading
        
        // Set up a readability handler to capture output chunks
        handle.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if data.isEmpty {
                // EOF reached
                handle.readabilityHandler = nil
                NSLog("sachinaaa_executeAsyncCommand EOF reached for PID \(process.processIdentifier)")
                DispatchQueue.main.async {
                    completion("", true, process.processIdentifier)
                }
                return
            }
            
            if let output = String(data: data, encoding: .utf8) {
                // Send each chunk as it arrives
                NSLog("sachinaaa_executeAsyncCommand output chunk: \(output) for PID \(process.processIdentifier)")
                DispatchQueue.main.async {
                    completion(output, false, process.processIdentifier)
                }
            }
        }
        
        process.terminationHandler = { proc in
            NSLog("sachinaaa_executeAsyncCommand process terminated with status \(proc.terminationStatus)")
            handle.readabilityHandler = nil
            
            // Ensure we always call completion with isLast=true when the process terminates
            DispatchQueue.main.async {
                completion("", true, proc.processIdentifier)
            }
        }
        
        do {
            try process.run()
            NSLog("sachinaaa_executeAsyncCommand process started with PID \(process.processIdentifier)")
        } catch {
            NSLog("sachinaaa_executeAsyncCommand ERROR: Failed to start process: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion("Error starting process: \(error.localizedDescription)", true, 0)
            }
        }
    }
}
