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

// MARK: - Helper

final class Helper: NSObject {

    // MARK: Properties

    let listener: NSXPCListener

    // MARK: Init

    override init() {
        listener = NSXPCListener(machServiceName: HelperConstants.domain)
        super.init()
        listener.delegate = self
    }
}

// MARK: - HelperProtocol

extension Helper: HelperProtocol {

    func executeScript(at path: [String]) async throws -> String {
        NSLog("Executing script at \(path)")
        do {
            return try await ExecutionService.executeScript(at: path)
        } catch {
            NSLog("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func executeCommand(_ command: String) async throws -> String {
        NSLog("Executing command: \(command)")
        do {
            return try await ExecutionService.executeCommand(command)
        } catch {
            NSLog("Error executing command: \(error.localizedDescription)")
            throw error
        }
    }
    
    func executeAsyncCommand(at path: [String], chunk completion: @escaping (String, Bool, Int32) -> Void) {
        NSLog("Executing async command at \(path)")
        ExecutionService.executeAsyncCommand(at: path) { chunk, isLast, pid in
            NSLog("sachinaaa_Helper_executeAsyncCommand Output: \(chunk). Is last: \(isLast). PID: \(pid)")
            completion(chunk, isLast, pid)
        }
    }
}

// MARK: - Run

extension Helper {

    func run() {
        // start listening on new connections
        listener.resume()

        // prevent the terminal application to exit
        RunLoop.current.run()
    }
}


// MARK: - NSXPCListenerDelegate

extension Helper: NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        do {
            try ConnectionIdentityService.checkConnectionIsValid(connection: newConnection)
        } catch {
            NSLog("🛑 Connection \(newConnection) has not been validated. \(error.localizedDescription)")
            return false
        }

        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.remoteObjectInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        newConnection.exportedObject = self

        newConnection.resume()
        return true
    }
}
