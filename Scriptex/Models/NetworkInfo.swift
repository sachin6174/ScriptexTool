import SwiftUI
import Network

@MainActor
class NetworkInfo: ObservableObject {
    @Published var publicIP: String = ""
    @Published var localIPs: [String] = []
    @Published var downloadSpeed: String = "0"
    @Published var uploadSpeed: String = "0"
    
    func update() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchPublicIP()
            }
            group.addTask {
                await self.fetchLocalIPs()
            }
            group.addTask {
                await self.fetchNetworkSpeed()
            }
        }
    }
    
    private func fetchPublicIP() async {
        do {
            let url = URL(string: "https://api.ipify.org")!
            let (data, _) = try await URLSession.shared.data(from: url)
            if let ip = String(data: data, encoding: .utf8) {
                publicIP = ip.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            publicIP = "Unable to fetch"
        }
    }
    
    private func fetchLocalIPs() async {
        var addresses: [String] = []
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface!.ifa_name)
                    if name == "en0" || name == "en1" || name.hasPrefix("en") {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(interface?.ifa_addr,
                                       socklen_t(interface?.ifa_addr.pointee.sa_len ?? 0),
                                       &hostname, socklen_t(hostname.count),
                                       nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                            let address = String(cString: hostname)
                            if addrFamily == UInt8(AF_INET) {
                                addresses.append(address)
                            }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        localIPs = addresses
    }
    
    private func fetchNetworkSpeed() async {
        downloadSpeed = "0"
        uploadSpeed = "0"
    }
}