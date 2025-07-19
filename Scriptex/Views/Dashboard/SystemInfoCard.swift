import SwiftUI

struct SystemInfoCard: View {
    @Binding var systemInfo: SystemInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.systemCard.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "desktopcomputer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.systemCard)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("System")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Device specifications")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "info.circle")
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
                // Primary Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Computer Name")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(AppColors.tertiaryText)
                            
                            Text(systemInfo.computerName.isEmpty ? "Loading..." : systemInfo.computerName)
                                .font(.system(size: 14, weight: .semibold, design: .default))
                                .foregroundColor(AppColors.primaryText)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("macOS Version")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(AppColors.tertiaryText)
                            
                            Text(systemInfo.macOSVersion.isEmpty ? "Loading..." : systemInfo.macOSVersion)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundColor(AppColors.primaryText)
                        }
                    }
                    
                    // Divider
                    Rectangle()
                        .fill(Color(NSColor.separatorColor))
                        .frame(height: 1)
                        .padding(.vertical, 4)
                }
                
                // Hardware Info
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Processor")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text(systemInfo.cpu.isEmpty ? "Loading..." : systemInfo.cpu)
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(AppColors.primaryText)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Memory")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(AppColors.tertiaryText)
                            
                            Text(systemInfo.memory.isEmpty ? "Loading..." : systemInfo.memory)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundColor(AppColors.primaryText)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Graphics")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(AppColors.tertiaryText)
                            
                            Text(systemInfo.graphics.isEmpty ? "Loading..." : systemInfo.graphics)
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(AppColors.primaryText)
                                .lineLimit(2)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Serial Number")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text(systemInfo.serialNumber.isEmpty ? "Loading..." : systemInfo.serialNumber)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(AppColors.cardBackground(for: AppColors.systemCard))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.systemCard.opacity(0.1), lineWidth: 1)
        )
    }
}