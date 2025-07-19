# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Scriptex is a macOS SwiftUI application that provides a system administration interface with privileged operations. The app uses a dual-architecture pattern with a main application and a privileged helper tool.

## Build & Development Commands

### Building the Application
```bash
# Build from Xcode
xcodebuild -project Scriptex.xcodeproj -scheme Scriptex -configuration Debug build

# Build release version
xcodebuild -project Scriptex.xcodeproj -scheme Scriptex -configuration Release build

# Build helper tool specifically
xcodebuild -project Scriptex.xcodeproj -scheme Helper -configuration Debug build
```

### Running the Application
```bash
# Open in Xcode for development
open Scriptex.xcodeproj

# Run from command line (after building)
./build/Debug/Scriptex.app/Contents/MacOS/Scriptex
```

## Architecture Overview

### Dual-Process Security Model
The application uses a privileged helper tool pattern required for macOS system administration:

- **Main App** (`Scriptex/`): SwiftUI interface running in user space
- **Helper Tool** (`Helper/`): Privileged daemon for system operations via XPC

### Key Components

#### Main Application Structure
- **ContentView.swift**: Root view with sidebar/detail split layout
- **SidebarView**: Navigation with items: Dashboard, Script Execution, App Manager, File Manager, User Management
- **Views/**: Feature-specific views organized by functionality
- **Models/**: Data structures (SystemInfo, NetworkInfo, UserInfo, etc.)
- **Services/**: Business logic including ExecutionService and UserManagementService

#### Helper Tool Architecture
- **Helper.swift**: NSXPCListener-based service implementing HelperProtocol
- **ExecutionService.swift**: Script execution engine (shared between app and helper)
- **ConnectionIdentityService.swift**: Security validation for XPC connections
- **HelperRemoteProvider.swift**: XPC connection management and helper installation

#### Cross-Process Communication
- **HelperProtocol**: Defines privileged operations (executeScript, executeAsyncCommand)
- **RemoteApplicationProtocol**: Callback interface for async operations
- **XPC Connection**: Secure IPC between main app and helper using ServiceManagement framework

### Installation & Privileges
The helper tool uses `SMJobBless` for privilege escalation and is installed to `/Library/PrivilegedHelperTools/`. Installation requires user authorization and is managed automatically by HelperRemoteProvider.

### Logging
Centralized logging via `Logger.swift` with categories:
- System: App lifecycle events
- ScriptExecution: Command execution with timing
- AsyncExecution: Real-time command output
- UIEvent: User interface interactions

### Security Features
- Code signing validation via ConnectionIdentityService
- XPC service isolation
- Privileged operations confined to helper tool
- Authorization checks using Security framework

## Development Notes

### Adding New Privileged Operations
1. Add method to `HelperProtocol`
2. Implement in `Helper.swift`
3. Add corresponding method in `ExecutionService` (main app)
4. Update XPC interface setup in both processes

### Working with Views
The app uses SwiftUI with a sidebar-detail layout. New features should follow the established pattern in `Views/` with corresponding models and services.

### Helper Tool Development
Changes to helper tool require rebuilding both targets. The helper is embedded in the main app bundle and installed on first connection attempt.