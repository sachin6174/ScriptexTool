#!/bin/bash

echo "🔍 Individual Swift Error Detection Commands"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_command() {
    echo -e "\n${BLUE}💡 Command: ${NC}$1"
    echo -e "${YELLOW}Description: ${NC}$2"
    echo "---"
}

print_section() {
    echo -e "\n${GREEN}📋 $1${NC}"
    echo "$(printf '%.0s=' {1..50})"
}

print_section "1. Basic Compilation Error Detection"

print_command "swiftc Sources/main.swift -o output" "Basic compilation to detect syntax and type errors"
echo "Output:"
swiftc Sources/main.swift -o output 2>&1 | head -10

print_command "swiftc Sources/main.swift -o output -v" "Verbose compilation with detailed output"
echo "Output (first few lines):"
swiftc Sources/main.swift -o output -v 2>&1 | head -5

print_section "2. Advanced Compiler Warnings"

print_command "swiftc Sources/main.swift -Wall" "Enable all compiler warnings"
echo "Output:"
swiftc Sources/main.swift -Wall 2>&1 | head -10

print_command "swiftc Sources/main.swift -Werror" "Treat warnings as errors"
echo "Output:"
swiftc Sources/main.swift -Werror 2>&1 | head -5

print_section "3. Static Analysis Options"

print_command "swiftc Sources/main.swift -strict-concurrency=complete" "Enable strict concurrency checking"
echo "Output:"
swiftc Sources/main.swift -strict-concurrency=complete 2>&1 | head -5

print_command "swiftc Sources/main.swift -enable-experimental-feature StrictConcurrency" "Experimental strict concurrency"
echo "Output:"
swiftc Sources/main.swift -enable-experimental-feature StrictConcurrency 2>&1 | head -5

print_section "4. Memory Safety Detection"

print_command "swiftc Sources/main.swift -sanitize=address" "Address Sanitizer for memory errors"
echo "Output:"
swiftc Sources/main.swift -sanitize=address 2>&1 | head -5

print_command "swiftc Sources/main.swift -sanitize=thread" "Thread Sanitizer for concurrency issues"
echo "Output:"
swiftc Sources/main.swift -sanitize=thread 2>&1 | head -5

print_section "5. Debug and Optimization Flags"

print_command "swiftc Sources/main.swift -g" "Include debug information"
echo "Output:"
swiftc Sources/main.swift -g 2>&1 | head -3

print_command "swiftc Sources/main.swift -O" "Optimize for performance"
echo "Output:"
swiftc Sources/main.swift -O 2>&1 | head -3

print_command "swiftc Sources/main.swift -Osize" "Optimize for size"
echo "Output:"
swiftc Sources/main.swift -Osize 2>&1 | head -3

print_section "6. Specific Error Type Detection"

print_command "swiftc Sources/main.swift -D DEBUG" "Compile with DEBUG flag"
echo "Output:"
swiftc Sources/main.swift -D DEBUG 2>&1 | head -3

print_command "swiftc Sources/main.swift -target arm64-apple-macos11.0" "Target specific platform"
echo "Output:"
swiftc Sources/main.swift -target arm64-apple-macos11.0 2>&1 | head -3

print_section "7. Parse-Only Checks"

print_command "swiftc -parse Sources/main.swift" "Parse only (no code generation)"
echo "Output:"
swiftc -parse Sources/main.swift 2>&1 | head -10

print_command "swiftc -typecheck Sources/main.swift" "Type checking only"
echo "Output:"
swiftc -typecheck Sources/main.swift 2>&1 | head -10

print_section "8. Diagnostic Options"

print_command "swiftc Sources/main.swift -Xfrontend -debug-diagnostic-names" "Show diagnostic names"
echo "Output:"
swiftc Sources/main.swift -Xfrontend -debug-diagnostic-names 2>&1 | head -10

print_command "swiftc Sources/main.swift -diagnostic-style=llvm" "Use LLVM diagnostic style"
echo "Output:"
swiftc Sources/main.swift -diagnostic-style=llvm 2>&1 | head -5

print_section "9. Batch Mode and Performance"

print_command "swiftc -wmo Sources/main.swift" "Whole Module Optimization"
echo "Output:"
swiftc -wmo Sources/main.swift 2>&1 | head -3

print_command "swiftc -num-threads 4 Sources/main.swift" "Use specific number of threads"
echo "Output:"
swiftc -num-threads 4 Sources/main.swift 2>&1 | head -3

print_section "10. Module and Import Analysis"

print_command "swiftc Sources/main.swift -dump-ast" "Dump Abstract Syntax Tree"
echo "Note: This generates extensive output, use with caution"

print_command "swiftc Sources/main.swift -emit-sil" "Emit Swift Intermediate Language"
echo "Note: This generates SIL code for advanced analysis"

print_section "SwiftLint Commands (if available)"

if command -v swiftlint >/dev/null 2>&1; then
    print_command "swiftlint" "Basic linting"
    swiftlint Sources/ 2>&1 | head -10
    
    print_command "swiftlint --strict" "Strict mode (warnings as errors)"
    swiftlint --strict Sources/ 2>&1 | head -5
    
    print_command "swiftlint --reporter json" "JSON format output"
    echo "Generates JSON report for integration with other tools"
    
    print_command "swiftlint --fix" "Auto-fix issues where possible"
    echo "Automatically fixes style issues that can be corrected"
else
    echo -e "${RED}⚠️  SwiftLint not installed. Install with: brew install swiftlint${NC}"
fi

print_section "Package Manager Commands (if available)"

if [ -f "Package.swift" ]; then
    print_command "swift build" "Build Swift package"
    echo "Note: Requires proper Package.swift configuration"
    
    print_command "swift test" "Run package tests"
    echo "Note: Requires XCTest framework"
    
    print_command "swift package show-dependencies" "Show dependency tree"
    echo "Note: Shows all package dependencies"
else
    echo "No Package.swift found - these commands require Swift Package Manager"
fi

print_section "Error Analysis Tips"

echo -e "${GREEN}📝 Tips for Effective Error Detection:${NC}"
echo ""
echo "1. Start with basic compilation: swiftc file.swift"
echo "2. Add warnings: swiftc file.swift -Wall"
echo "3. Use parse-only for syntax: swiftc -parse file.swift"
echo "4. Check types only: swiftc -typecheck file.swift"
echo "5. Memory safety: swiftc file.swift -sanitize=address"
echo "6. Style checking: swiftlint (if installed)"
echo "7. Verbose output: Add -v flag for detailed information"
echo "8. Treat warnings as errors: -Werror for strict checking"
echo ""
echo -e "${YELLOW}🔧 Common Error Types to Look For:${NC}"
echo "• Syntax errors (missing brackets, semicolons)"
echo "• Type mismatches (String vs Int, etc.)"
echo "• Undefined variables/functions"
echo "• Memory leaks and retain cycles"
echo "• Force unwrapping of optionals"
echo "• Array bounds violations"
echo "• Naming convention violations"
echo "• Unused variables and imports"
echo ""
echo -e "${BLUE}💡 Integration with IDEs:${NC}"
echo "• Xcode: Built-in error detection and highlighting"
echo "• VS Code: Swift extension with Language Server Protocol"
echo "• Vim/Neovim: Swift plugins with syntax checking"
echo "• Command line: Use these commands in build scripts"

echo -e "\n${GREEN}✅ Individual error detection guide complete!${NC}"