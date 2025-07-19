import SwiftUI

struct NetworkInfoCard: View {
    @Binding var networkInfo: NetworkInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.networkCard.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "network")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.networkCard)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Network")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Connection details")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                Spacer()
                
                Button(action: { updateNetworkInfo() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                // Public IP
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Public IP")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text(networkInfo.publicIP.isEmpty ? "Loading..." : networkInfo.publicIP)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    Spacer()
                    
                    if !networkInfo.publicIP.isEmpty {
                        Circle()
                            .fill(AppColors.secondaryAccent)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Local IPs
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local Network")
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Text(networkInfo.localIPs.isEmpty ? "Loading..." : networkInfo.localIPs.joined(separator: ", "))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(2)
                }
                
                // Network Speed
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppColors.secondaryAccent)
                            
                            Text("Download")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(AppColors.tertiaryText)
                        }
                        
                        Text("\(networkInfo.downloadSpeed) KB/s")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppColors.quaternaryAccent)
                            
                            Text("Upload")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(AppColors.tertiaryText)
                        }
                        
                        Text("\(networkInfo.uploadSpeed) KB/s")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppColors.primaryText)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(AppColors.cardBackground(for: AppColors.networkCard))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.networkCard.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            updateNetworkInfo()
        }
    }
    
    private func updateNetworkInfo() {
        Task {
            await networkInfo.update()
        }
    }
}