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
import ServiceManagement

// MARK: - HelperRemoteProvider

/// Provide a `HelperProtocol` object to request the helper.
enum HelperRemoteProvider {

    // MARK: Computed

    private static var isHelperInstalled: Bool { FileManager.default.fileExists(atPath: HelperConstants.helperPath) }
}

// MARK: - Remote

extension HelperRemoteProvider {

    static func remote() async throws -> some HelperProtocol {
        let connection = try connection()
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<any HelperProtocol, Error>) in
            let continuationResume = ContinuationResume()
            
            let helper = connection.remoteObjectProxyWithErrorHandler { error in
                // Use shouldResume to ensure continuation is resumed at most once
                if continuationResume.shouldResume() {
                    continuation.resume(throwing: error)
                }
            }
            
            // Ensure we don't resume the continuation if the error handler already did
            DispatchQueue.main.async {
                if continuationResume.shouldResume() {
                    if let unwrappedHelper = helper as? HelperProtocol {
                        continuation.resume(returning: unwrappedHelper)
                    } else {
                        // Only attempt to resume if we haven't already
                        let error = ScriptexError.helperConnection("Unable to get a valid 'HelperProtocol' object for an unknown reason")
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}

// MARK: - Install helper

extension HelperRemoteProvider {

    /// Install the Helper in the privileged helper tools folder and load the daemon
    private static func installHelper() throws {

        // try to get a valid empty authorization
        var authRef: AuthorizationRef?
        try AuthorizationCreate(nil, nil, [.preAuthorize], &authRef).checkError("AuthorizationCreate")
        defer {
            if let authRef {
                AuthorizationFree(authRef, [])
            }
        }

        // create an AuthorizationItem to specify we want to bless a privileged Helper
        let authStatus = kSMRightBlessPrivilegedHelper.withCString { authorizationString in
            var authItem = AuthorizationItem(name: authorizationString, valueLength: 0, value: nil, flags: 0)

            return withUnsafeMutablePointer(to: &authItem) { pointer in
                var authRights = AuthorizationRights(count: 1, items: pointer)
                let flags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]
                return AuthorizationCreate(&authRights, nil, flags, &authRef)
            }
        }

        guard authStatus == errAuthorizationSuccess else {
           throw ScriptexError.helperInstallation("Unable to get a valid loading authorization reference to load Helper daemon")
        }

        var blessErrorPointer: Unmanaged<CFError>?
        let wasBlessed = SMJobBless(kSMDomainSystemLaunchd, HelperConstants.domain as CFString, authRef, &blessErrorPointer)

        guard !wasBlessed else { return }
        // throw error since authorization was not blessed
        let blessError: Error = if let blessErrorPointer {
            blessErrorPointer.takeRetainedValue() as Error
        } else {
            ScriptexError.unknown
        }
        throw ScriptexError.helperInstallation("Error while installing the Helper: \(blessError.localizedDescription)")
    }
}

// MARK: - Connection

extension HelperRemoteProvider {

    static private func connection() throws -> NSXPCConnection {
        if !isHelperInstalled {
            try installHelper()
        }
        return createConnection()
    }

    private static func createConnection() -> NSXPCConnection {
        let connection = NSXPCConnection(machServiceName: HelperConstants.domain, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.exportedInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        connection.exportedObject = self

        connection.invalidationHandler = {
            if isHelperInstalled {
                print("Unable to connect to Helper although it is installed")
            } else {
                print("Helper is not installed")
            }
        }

        connection.resume()

        return connection
    }
}

// MARK: - ContinuationResume

extension HelperRemoteProvider {

    /// Helper class to safely access a boolean when using a continuation to get the remote.
    private final class ContinuationResume: @unchecked Sendable {

        // MARK: Properties

        private let unfairLockPointer: UnsafeMutablePointer<os_unfair_lock_s>
        private var alreadyResumed = false

        // MARK: Computed

        /// `true` if the continuation should resume.
        func shouldResume() -> Bool {
            os_unfair_lock_lock(unfairLockPointer)
            defer { os_unfair_lock_unlock(unfairLockPointer) }

            if alreadyResumed {
                return false
            } else {
                alreadyResumed = true
                return true
            }
        }

        // MARK: Init

        init() {
            unfairLockPointer = UnsafeMutablePointer<os_unfair_lock_s>.allocate(capacity: 1)
            unfairLockPointer.initialize(to: os_unfair_lock())
        }

        deinit {
            unfairLockPointer.deallocate()
        }
    }
}
