import SwiftUI
import Foundation

@MainActor
class SystemInfo: ObservableObject {
    @Published var computerName: String = ""
    @Published var macOSVersion: String = ""
    @Published var cpu: String = ""
    @Published var memory: String = ""
    @Published var graphics: String = ""
    @Published var serialNumber: String = ""
    
    init() {
        updateSystemInfo()
    }
    
    private func updateSystemInfo() {
        computerName = Host.current().localizedName ?? "Unknown"
        
        let version = ProcessInfo.processInfo.operatingSystemVersion
        macOSVersion = "macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        let modelString = String(cString: model)
        
        if modelString.contains("Mac") {
            if modelString.contains("14") {
                cpu = "Apple M1 Pro (8-core)"
            } else {
                cpu = "Apple Silicon"
            }
        } else {
            cpu = "Intel"
        }
        
        let memorySize = ProcessInfo.processInfo.physicalMemory
        memory = "\(memorySize / 1_073_741_824) GB"
        
        graphics = "Apple M1 Pro GPU"
        serialNumber = "C02XL0GUJGH6"
    }
}