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
        Logger.shared.info("Starting script execution", category: "ScriptExecution")
        Logger.shared.debug("Script path: \(path)", category: "ScriptExecution")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let result = try await HelperRemoteProvider.remote().executeScript(at: path)
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            
            Logger.shared.logScriptExecution(
                path: path.joined(separator: " "),
                success: true,
                output: result,
                duration: duration
            )
            
            return result
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            
            Logger.shared.logScriptExecution(
                path: path.joined(separator: " "),
                success: false,
                output: error.localizedDescription,
                duration: duration
            )
            
            throw error
        }
    }
    
    /// Execute a shell command directly.
    static func executeCommand(_ command: String) async throws -> String {
        Logger.shared.info("Starting command execution", category: "CommandExecution")
        Logger.shared.debug("Command: \(command)", category: "CommandExecution")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let result = try await HelperRemoteProvider.remote().executeCommand(command)
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            
            Logger.shared.logScriptExecution(
                path: "Direct Command: \(command)",
                success: true,
                output: result,
                duration: duration
            )
            
            return result
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            
            Logger.shared.logScriptExecution(
                path: "Direct Command: \(command)",
                success: false,
                output: error.localizedDescription,
                duration: duration
            )
            
            throw error
        }
    }
    
    static func executeAsyncCommand(
        at path: [String],
        completion: @escaping (_ chunk: String, _ isLast: Bool, _ pid: Int32) -> ()
    ) async throws {
        Logger.shared.info("Starting async command execution", category: "AsyncExecution")
        Logger.shared.debug("Async command path: \(path)", category: "AsyncExecution")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        var outputBuffer = ""
        
        do {
            let remote = try await HelperRemoteProvider.remote()
            
            remote.executeAsyncCommand(at: path) { (chunk, isLast, pid) in
                if !chunk.isEmpty {
                    outputBuffer += chunk
                    Logger.shared.debug("Received chunk (\(chunk.count) chars) from PID \(pid)", category: "AsyncExecution")
                }
                
                if isLast {
                    let duration = CFAbsoluteTimeGetCurrent() - startTime
                    Logger.shared.logScriptExecution(
                        path: path.joined(separator: " "),
                        success: true,
                        output: outputBuffer,
                        duration: duration,
                        exitCode: 0
                    )
                }
                
                completion(chunk, isLast, pid)
            }
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            Logger.shared.logScriptExecution(
                path: path.joined(separator: " "),
                success: false,
                output: error.localizedDescription,
                duration: duration
            )
            throw error
        }
    }
}
