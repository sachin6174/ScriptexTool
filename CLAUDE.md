# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Scriptex is a macOS application built with SwiftUI that provides system administration and script execution capabilities through a privileged helper tool. The app uses Apple's SMJobBless framework for secure privilege escalation and XPC communication between the main app and helper process.

## Build Commands

The project uses Xcode build system with two main targets:

- **Build main app**: `xcodebuild -scheme Scriptex -configuration Debug build`
- **Build helper tool**: `xcodebuild -scheme Helper -configuration Debug build`
- **Build for release**: `xcodebuild -scheme Scriptex -configuration Release build`
- **Clean build**: `xcodebuild -scheme Scriptex clean`

## Architecture

### Main Components

1. **Main App (`Scriptex/`)**: SwiftUI-based macOS application
   - Entry point: `ScriptexApp.swift`
   - Main UI: `ContentView.swift` with sidebar navigation
   - Views organized by feature: Dashboard, ScriptExecution, AppManager, FileManager

2. **Privileged Helper (`Helper/`)**: Background daemon for privileged operations
   - Entry point: `main.swift`
   - Core logic: `Helper.swift`
   - XPC communication via `HelperProtocol.swift`

3. **Shared Code**: Common protocols and services used by both targets
   - `ExecutionService.swift`: Script execution logic
   - `HelperProtocol.swift`: XPC interface definition
   - `ScriptexError.swift`: Error handling

### Key Patterns

- **XPC Communication**: Main app communicates with helper via `HelperRemoteProvider.swift`
- **MVVM Architecture**: Views use `@State` and `@Binding` for data flow
- **Logging**: Centralized logging via `Logger.swift` utility
- **Security**: Helper tool installed as privileged daemon using SMJobBless

### Installation Scripts

- `preinstall.sh`: Pre-installation setup script
- `postInstall.sh`: Post-installation configuration script
- `SMJobBlessUtil.py`: Utility for managing privileged helper installation

## Code Organization

```
Scriptex/
├── Views/              # Feature-based view organization
│   ├── Dashboard/      # System information display
│   ├── ScriptExecution/ # Script running interface
│   ├── AppManager/     # Application management
│   └── FileManager/    # File system operations
├── Models/             # Data models (SystemInfo, NetworkInfo, etc.)
├── Components/         # Reusable UI components
└── Utils/              # Utility classes (Logger, etc.)

Helper/                 # Privileged helper tool
├── main.swift          # Helper entry point
├── Helper.swift        # XPC service implementation
└── ExecutionService.swift # Script execution backend
```

## Key Files for Common Tasks

- **UI Modifications**: Start with `ContentView.swift` and relevant view in `Views/`
- **Script Execution**: Modify `ExecutionService.swift` in either target
- **XPC Communication**: Update `HelperProtocol.swift` and `HelperRemoteProvider.swift`
- **System Information**: Edit models in `Models/` directory
- **Logging**: Use `Logger.shared` throughout the codebase

## Security Considerations

This application handles privileged operations through a helper tool. When modifying:
- Always validate input in both app and helper
- Use proper XPC communication patterns
- Follow principle of least privilege
- Test privilege escalation scenarios carefully

## Swift Error Detection System

A comprehensive Swift error detection system is available in the `SwiftErrorDetection/` directory:

### Quick Start
```bash
cd SwiftErrorDetection
./check_errors.sh              # Run complete error analysis
./individual_checks.sh          # Learn individual commands
```

### Key Features
- **Compilation Error Detection**: Syntax, type, and logic errors
- **Memory Safety Analysis**: Address/thread sanitizers for memory leaks
- **Code Quality Checks**: SwiftLint integration for style enforcement
- **Advanced Compiler Flags**: Strict concurrency, warnings as errors
- **Automated Reporting**: Detailed logs and HTML reports
- **Educational Examples**: Intentional errors with corrections

### Files Structure
```
SwiftErrorDetection/
├── Package.swift                 # Swift package configuration
├── Sources/main.swift           # Code with intentional errors
├── Tests/                       # Unit test examples
├── check_errors.sh             # Comprehensive error detection
├── individual_checks.sh        # Individual command examples
├── .swiftlint.yml              # SwiftLint configuration
└── error_logs/                 # Generated error reports
```

### Common Error Detection Commands
```bash
# Basic compilation
swiftc Sources/main.swift -o output

# Enable all warnings
swiftc Sources/main.swift -Wall

# Memory safety checks
swiftc Sources/main.swift -sanitize=address

# Parse and type checking only
swiftc -parse Sources/main.swift
swiftc -typecheck Sources/main.swift

# Code style (requires SwiftLint)
swiftlint Sources/
```

### Error Types Detected
- Syntax errors (missing brackets, incorrect keywords)
- Type mismatches (String/Int conflicts)
- Memory issues (retain cycles, leaks)
- Runtime crashes (force unwrapping, array bounds)
- Style violations (naming conventions, unused variables)
- Concurrency issues (data races, deadlocks)

Take care of:
- Min OS Req: 11.5
- UI: Storyboard/SwiftUI
- When adding/deleting files or groups, update project.pbxproj file