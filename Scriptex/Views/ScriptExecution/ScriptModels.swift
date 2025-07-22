import Foundation

enum ScriptReturnType: String, CaseIterable {
    case integer = "Integer"
    case double = "Double"
    case string = "String"
    case boolean = "Boolean"
    case json = "JSON"
    case array = "Array"
    
    var color: NSColor {
        switch self {
        case .integer: return .systemBlue
        case .double: return .systemPurple
        case .string: return .systemGreen
        case .boolean: return .systemOrange
        case .json: return .systemRed
        case .array: return .systemTeal
        }
    }
    
    var icon: String {
        switch self {
        case .integer: return "number"
        case .double: return "dot.radiowaves.left.and.right"
        case .string: return "textformat.abc"
        case .boolean: return "checkmark.circle"
        case .json: return "curlybraces"
        case .array: return "list.bullet"
        }
    }
}

struct PredefinedScript: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let command: String
    let returnType: ScriptReturnType
    let category: String
    
    init(_ name: String, description: String, command: String, returnType: ScriptReturnType, category: String) {
        self.name = name
        self.description = description
        self.command = command
        self.returnType = returnType
        self.category = category
    }
    
    static let allScripts: [PredefinedScript] = [
        // MARK: - Integer Scripts
        PredefinedScript(
            "System CPU Count",
            description: "Get the number of CPU cores",
            command: "sysctl -n hw.ncpu",
            returnType: .integer,
            category: "System Info"
        ),
        
        PredefinedScript(
            "Memory Size (GB)",
            description: "Get total system memory in GB",
            command: "echo $(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))",
            returnType: .integer,
            category: "System Info"
        ),
        
        PredefinedScript(
            "Current Process Count",
            description: "Count running processes",
            command: "ps aux | wc -l",
            returnType: .integer,
            category: "System Info"
        ),
        
        PredefinedScript(
            "Disk Usage (GB)",
            description: "Get disk usage in GB for root partition",
            command: "df / | awk 'NR==2 {print int($3/1024/1024)}'",
            returnType: .integer,
            category: "Storage"
        ),
        
        PredefinedScript(
            "Files in Downloads",
            description: "Count files in Downloads folder",
            command: "find ~/Downloads -type f | wc -l",
            returnType: .integer,
            category: "File System"
        ),
        
        PredefinedScript(
            "Current Year",
            description: "Get the current year",
            command: "date +%Y",
            returnType: .integer,
            category: "Date/Time"
        ),
        
        PredefinedScript(
            "Random Number (1-100)",
            description: "Generate random number between 1 and 100",
            command: "echo $((RANDOM % 100 + 1))",
            returnType: .integer,
            category: "Utilities"
        ),
        
        // MARK: - Double Scripts
        PredefinedScript(
            "CPU Usage Percentage",
            description: "Get current CPU usage percentage",
            command: "top -l 1 | grep 'CPU usage' | awk '{print $3}' | sed 's/%//'",
            returnType: .double,
            category: "Performance"
        ),
        
        PredefinedScript(
            "Memory Usage Percentage",
            description: "Calculate memory usage percentage",
            command: "echo \"scale=2; $(memory_pressure | grep 'System-wide memory free percentage' | awk '{print $5}' | sed 's/%//') / 1\" | bc",
            returnType: .double,
            category: "Performance"
        ),
        
        PredefinedScript(
            "Load Average (1min)",
            description: "Get 1-minute load average",
            command: "uptime | awk -F'load averages: ' '{print $2}' | awk '{print $1}'",
            returnType: .double,
            category: "Performance"
        ),
        
        PredefinedScript(
            "Battery Percentage",
            description: "Get battery charge percentage (if available)",
            command: "pmset -g batt | grep -Eo '\\d+%' | head -1 | sed 's/%//'",
            returnType: .double,
            category: "Hardware"
        ),
        
        PredefinedScript(
            "Disk Usage Ratio",
            description: "Get disk usage ratio (used/total)",
            command: "df / | awk 'NR==2 {printf \"%.2f\", $3/$2}'",
            returnType: .double,
            category: "Storage"
        ),
        
        PredefinedScript(
            "Random Float (0-1)",
            description: "Generate random float between 0 and 1",
            command: "echo \"scale=6; $RANDOM / 32767\" | bc",
            returnType: .double,
            category: "Utilities"
        ),
        
        // MARK: - String Scripts
        PredefinedScript(
            "System Hostname",
            description: "Get system hostname",
            command: "hostname",
            returnType: .string,
            category: "System Info"
        ),
        
        PredefinedScript(
            "Current Username",
            description: "Get current logged-in user",
            command: "whoami",
            returnType: .string,
            category: "User Info"
        ),
        
        PredefinedScript(
            "macOS Version",
            description: "Get macOS version information",
            command: "sw_vers -productVersion",
            returnType: .string,
            category: "System Info"
        ),
        
        PredefinedScript(
            "Current Working Directory",
            description: "Get current working directory",
            command: "pwd",
            returnType: .string,
            category: "File System"
        ),
        
        PredefinedScript(
            "Home Directory",
            description: "Get user home directory path",
            command: "echo $HOME",
            returnType: .string,
            category: "File System"
        ),
        
        PredefinedScript(
            "Current Date & Time",
            description: "Get formatted current date and time",
            command: "date '+%Y-%m-%d %H:%M:%S'",
            returnType: .string,
            category: "Date/Time"
        ),
        
        PredefinedScript(
            "System Uptime",
            description: "Get system uptime information",
            command: "uptime | awk -F'up ' '{print $2}' | awk -F', load' '{print $1}'",
            returnType: .string,
            category: "System Info"
        ),
        
        PredefinedScript(
            "Current Shell",
            description: "Get current shell information",
            command: "echo $SHELL",
            returnType: .string,
            category: "Environment"
        ),
        
        PredefinedScript(
            "Random UUID",
            description: "Generate a random UUID",
            command: "uuidgen",
            returnType: .string,
            category: "Utilities"
        ),
        
        PredefinedScript(
            "Git User Name",
            description: "Get Git global user name (if configured)",
            command: "git config --global user.name 2>/dev/null || echo 'Not configured'",
            returnType: .string,
            category: "Development"
        ),
        
        // MARK: - Boolean Scripts
        PredefinedScript(
            "Internet Connection Check",
            description: "Check if internet connection is available",
            command: "ping -c 1 google.com >/dev/null 2>&1 && echo 'true' || echo 'false'",
            returnType: .boolean,
            category: "Network"
        ),
        
        PredefinedScript(
            "Is Docker Running",
            description: "Check if Docker is running",
            command: "docker info >/dev/null 2>&1 && echo 'true' || echo 'false'",
            returnType: .boolean,
            category: "Development"
        ),
        
        PredefinedScript(
            "Is Git Repository",
            description: "Check if current directory is a Git repository",
            command: "git rev-parse --is-inside-work-tree >/dev/null 2>&1 && echo 'true' || echo 'false'",
            returnType: .boolean,
            category: "Development"
        ),
        
        PredefinedScript(
            "Has Admin Rights",
            description: "Check if current user has admin privileges",
            command: "dscl . -read /Groups/admin GroupMembership | grep -q $(whoami) && echo 'true' || echo 'false'",
            returnType: .boolean,
            category: "Security"
        ),
        
        PredefinedScript(
            "Is Dark Mode Enabled",
            description: "Check if macOS dark mode is enabled",
            command: "defaults read -g AppleInterfaceStyle >/dev/null 2>&1 && echo 'true' || echo 'false'",
            returnType: .boolean,
            category: "System Info"
        ),
        
        PredefinedScript(
            "File Exists Check",
            description: "Check if ~/.bashrc file exists",
            command: "test -f ~/.bashrc && echo 'true' || echo 'false'",
            returnType: .boolean,
            category: "File System"
        ),
        
        PredefinedScript(
            "Is On Battery Power",
            description: "Check if running on battery power",
            command: "pmset -g ps | grep -q 'Battery Power' && echo 'true' || echo 'false'",
            returnType: .boolean,
            category: "Hardware"
        ),
        
        // MARK: - JSON Scripts
        PredefinedScript(
            "System Information JSON",
            description: "Get comprehensive system info as JSON",
            command: """
            echo "{\\"hostname\\": \\"$(hostname)\\", \\"user\\": \\"$(whoami)\\", \\"os\\": \\"$(sw_vers -productVersion)\\", \\"uptime\\": \\"$(uptime | awk -F'up ' '{print $2}' | awk -F', load' '{print $1}')\\", \\"cpu_cores\\": $(sysctl -n hw.ncpu), \\"memory_gb\\": $(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))}"
            """,
            returnType: .json,
            category: "System Info"
        ),
        
        PredefinedScript(
            "Network Information JSON",
            description: "Get network interface information as JSON",
            command: """
            echo "{\\"interfaces\\": [" && ifconfig | grep '^[a-z]' | awk '{print "{\\"name\\": \\""$1"\\", \\"status\\": \\"active\\"}"}' | head -3 | paste -sd ',' - && echo "]}"
            """,
            returnType: .json,
            category: "Network"
        ),
        
        PredefinedScript(
            "Disk Usage JSON",
            description: "Get disk usage information as JSON",
            command: """
            df -h / | awk 'NR==2 {print "{\\"filesystem\\": \\""$1"\\", \\"size\\": \\""$2"\\", \\"used\\": \\""$3"\\", \\"available\\": \\""$4"\\", \\"usage_percent\\": \\""$5"\\"}"}'
            """,
            returnType: .json,
            category: "Storage"
        ),
        
        PredefinedScript(
            "Environment Variables JSON",
            description: "Get key environment variables as JSON",
            command: """
            echo "{\\"HOME\\": \\"$HOME\\", \\"USER\\": \\"$USER\\", \\"SHELL\\": \\"$SHELL\\", \\"PATH\\": \\"$(echo $PATH | cut -c1-100)...\\", \\"PWD\\": \\"$PWD\\"}"
            """,
            returnType: .json,
            category: "Environment"
        ),
        
        PredefinedScript(
            "Git Repository Status JSON",
            description: "Get Git repository status as JSON",
            command: """
            if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                echo "{\\"is_git_repo\\": true, \\"branch\\": \\"$(git branch --show-current)\\", \\"status\\": \\"$(git status --porcelain | wc -l) files changed\\", \\"remote\\": \\"$(git remote get-url origin 2>/dev/null || echo 'none')\\"}"
            else
                echo "{\\"is_git_repo\\": false, \\"message\\": \\"Not a Git repository\\"}"
            fi
            """,
            returnType: .json,
            category: "Development"
        ),
        
        // MARK: - Array Scripts
        PredefinedScript(
            "Running Processes List",
            description: "Get list of top 10 running processes",
            command: "ps aux | head -11 | tail -10 | awk '{print $11}' | tr '\\n' ',' | sed 's/,$//'",
            returnType: .array,
            category: "System Info"
        ),
        
        PredefinedScript(
            "Network Interfaces List",
            description: "Get list of network interfaces",
            command: "ifconfig | grep '^[a-z]' | awk '{print $1}' | sed 's/://' | tr '\\n' ',' | sed 's/,$//'",
            returnType: .array,
            category: "Network"
        ),
        
        PredefinedScript(
            "Environment Variables List",
            description: "Get list of environment variable names",
            command: "env | cut -d= -f1 | head -20 | tr '\\n' ',' | sed 's/,$//'",
            returnType: .array,
            category: "Environment"
        ),
        
        PredefinedScript(
            "Installed Homebrew Packages",
            description: "Get list of installed Homebrew packages",
            command: "brew list 2>/dev/null | head -15 | tr '\\n' ',' | sed 's/,$//' || echo 'Homebrew not installed'",
            returnType: .array,
            category: "Development"
        ),
        
        PredefinedScript(
            "Recently Modified Files",
            description: "Get list of recently modified files in current directory",
            command: "find . -type f -mtime -1 2>/dev/null | head -10 | tr '\\n' ',' | sed 's/,$//'",
            returnType: .array,
            category: "File System"
        ),
        
        PredefinedScript(
            "Shell History Commands",
            description: "Get list of recent shell commands (last 10)",
            command: "history | tail -10 | awk '{$1=\"\"; print substr($0,2)}' | tr '\\n' ',' | sed 's/,$//'",
            returnType: .array,
            category: "Utilities"
        )
    ]
    
    static func scripts(for returnType: ScriptReturnType) -> [PredefinedScript] {
        return allScripts.filter { $0.returnType == returnType }
    }
    
    static func scripts(for category: String) -> [PredefinedScript] {
        return allScripts.filter { $0.category == category }
    }
    
    static var categories: [String] {
        return Array(Set(allScripts.map { $0.category })).sorted()
    }
}