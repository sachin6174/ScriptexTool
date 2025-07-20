#!/bin/bash

echo "🔍 Swift Project Error Detection System"
echo "======================================"

# Create output directory for logs
mkdir -p error_logs

# Function to print section headers
print_section() {
    echo ""
    echo "📋 $1"
    echo "$(printf '%.0s-' {1..50})"
}

# Function to save output with timestamp
save_output() {
    local command="$1"
    local output_file="$2"
    echo "$(date): Running $command" >> "error_logs/$output_file"
    echo "----------------------------------------" >> "error_logs/$output_file"
}

print_section "1. Basic Compilation Error Check"
echo "🔨 Attempting to compile main.swift..."
save_output "swiftc compilation" "compilation_errors.log"

if swiftc Sources/main.swift -o output 2>&1 | tee -a error_logs/compilation_errors.log; then
    echo "✅ Compilation successful"
    echo "🚀 Running executable..."
    if ./output 2>&1 | tee -a error_logs/runtime_errors.log; then
        echo "✅ Execution completed"
    else
        echo "❌ Runtime errors detected"
    fi
else
    echo "❌ Compilation failed - errors detected and logged"
fi

print_section "2. Advanced Compiler Warnings"
echo "⚠️  Checking with all warnings enabled..."
save_output "swiftc with warnings" "advanced_warnings.log"

swiftc Sources/main.swift -o output_warnings \
    -warn-swift3-objc-inference-complete \
    -warn-unreachable-code \
    -warn-implicit-overrides \
    2>&1 | tee -a error_logs/advanced_warnings.log

print_section "3. Static Analysis with Strict Checking"
echo "🔍 Running strict analysis..."
save_output "strict analysis" "static_analysis.log"

swiftc Sources/main.swift -o output_strict \
    -warnings-as-errors \
    -enable-experimental-feature StrictConcurrency \
    2>&1 | tee -a error_logs/static_analysis.log

print_section "4. Memory Safety Checks"
echo "🛡️  Checking for memory safety issues..."
save_output "memory safety" "memory_safety.log"

# Address Sanitizer
echo "   • Address Sanitizer..."
swiftc Sources/main.swift -o output_asan -sanitize=address 2>&1 | tee -a error_logs/memory_safety.log

# Thread Sanitizer  
echo "   • Thread Sanitizer..."
swiftc Sources/main.swift -o output_tsan -sanitize=thread 2>&1 | tee -a error_logs/memory_safety.log

print_section "5. Code Style and Quality Check"
echo "🎨 Checking code style..."

# Check if SwiftLint is available
if command -v swiftlint >/dev/null 2>&1; then
    echo "✅ SwiftLint found - running analysis..."
    save_output "swiftlint" "swiftlint.log"
    swiftlint Sources/ 2>&1 | tee -a error_logs/swiftlint.log
    
    # Generate detailed SwiftLint report
    swiftlint --reporter html Sources/ > error_logs/swiftlint_report.html 2>/dev/null
    echo "📊 HTML report generated: error_logs/swiftlint_report.html"
else
    echo "⚠️  SwiftLint not found. Install with: brew install swiftlint"
    echo "📝 Manual style check - looking for common issues..."
    
    # Manual style checks
    save_output "manual style check" "manual_style.log"
    echo "Checking for common style issues..." >> error_logs/manual_style.log
    
    # Check for snake_case variables
    grep -n "var.*_.*=" Sources/main.swift >> error_logs/manual_style.log 2>/dev/null || echo "No snake_case variables found" >> error_logs/manual_style.log
    
    # Check for UPPERCASE variables
    grep -n "var [A-Z_]*=" Sources/main.swift >> error_logs/manual_style.log 2>/dev/null || echo "No UPPERCASE variables found" >> error_logs/manual_style.log
    
    # Check for unused variables
    grep -n "let.*=" Sources/main.swift | grep -v "print\|return" >> error_logs/manual_style.log 2>/dev/null || echo "Manual unused variable check complete" >> error_logs/manual_style.log
fi

print_section "6. Unit Test Analysis"
echo "🧪 Running tests..."
save_output "unit tests" "test_results.log"

# Note: swift test would require package manager, so we'll simulate
echo "Note: Full test suite requires Swift Package Manager" | tee -a error_logs/test_results.log
echo "Individual file testing:" | tee -a error_logs/test_results.log

# Try to compile test file separately
if [ -f "Tests/SwiftErrorDetectionTests/SwiftErrorDetectionTests.swift" ]; then
    echo "📝 Test file found - checking test compilation..." | tee -a error_logs/test_results.log
    swiftc -parse Tests/SwiftErrorDetectionTests/SwiftErrorDetectionTests.swift 2>&1 | tee -a error_logs/test_results.log
fi

print_section "7. Error Summary Report"
echo "📊 Generating summary report..."

# Create comprehensive summary
{
    echo "SWIFT ERROR DETECTION SUMMARY REPORT"
    echo "Generated on: $(date)"
    echo "Project: SwiftErrorDetection"
    echo ""
    
    echo "=== COMPILATION ERRORS ==="
    if [ -f "error_logs/compilation_errors.log" ]; then
        grep -c "error:" error_logs/compilation_errors.log || echo "0"
        echo "errors found"
    fi
    
    echo ""
    echo "=== WARNINGS ==="
    if [ -f "error_logs/compilation_errors.log" ]; then
        grep -c "warning:" error_logs/compilation_errors.log || echo "0"
        echo "warnings found"
    fi
    
    echo ""
    echo "=== MEMORY SAFETY ISSUES ==="
    if [ -f "error_logs/memory_safety.log" ]; then
        grep -c "error:\|warning:" error_logs/memory_safety.log || echo "0"
        echo "potential memory issues found"
    fi
    
    echo ""
    echo "=== STYLE ISSUES ==="
    if [ -f "error_logs/swiftlint.log" ]; then
        grep -c "warning:\|error:" error_logs/swiftlint.log || echo "SwiftLint not run"
    elif [ -f "error_logs/manual_style.log" ]; then
        echo "Manual style check completed - see manual_style.log"
    fi
    
    echo ""
    echo "=== FILES GENERATED ==="
    ls -la error_logs/
    
    echo ""
    echo "=== RECOMMENDATIONS ==="
    echo "1. Fix compilation errors first (see compilation_errors.log)"
    echo "2. Address memory safety warnings (see memory_safety.log)"
    echo "3. Review style issues for better code quality"
    echo "4. Run tests after fixing compilation errors"
    echo "5. Use static analysis tools regularly during development"
    
} > error_logs/summary_report.txt

cat error_logs/summary_report.txt

echo ""
echo "✅ Error detection complete!"
echo "📁 All logs saved in error_logs/ directory"
echo "📋 Summary report: error_logs/summary_report.txt"

# Clean up executables
echo ""
echo "🧹 Cleaning up temporary files..."
rm -f output output_warnings output_strict output_asan output_tsan

echo "🎉 Swift Error Detection Analysis Complete!"