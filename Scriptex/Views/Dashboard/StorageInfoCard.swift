import SwiftUI

struct StorageInfoCard: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.storageCard.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "externaldrive")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.storageCard)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Storage")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Disk usage overview")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                Spacer()
                
                Button(action: {}) {
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
                // Usage Progress
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Disk Usage")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Spacer()
                        
                        Text("\(Int(getStorageUsagePercentage() * 100))%")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.separatorColor))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.storageCard,
                                        AppColors.storageCard.opacity(0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: geometry.size.width * getStorageUsagePercentage(), height: 12)
                        }
                    }
                    .frame(height: 12)
                }
                
                // Storage Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Total")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Spacer()
                        
                        Text(getTotalStorage())
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    HStack {
                        Text("Available")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Spacer()
                        
                        Text(getAvailableStorage())
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppColors.secondaryAccent)
                    }
                    
                    HStack {
                        Text("Used")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Spacer()
                        
                        Text(getUsedStorage())
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppColors.primaryText)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(AppColors.cardBackground(for: AppColors.storageCard))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.storageCard.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func getTotalStorage() -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            if let resourceValues = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey]) {
                if let totalCapacity = resourceValues.volumeTotalCapacity {
                    return ByteCountFormatter.string(fromByteCount: Int64(totalCapacity), countStyle: .file)
                }
            }
        }
        return "Unknown"
    }
    
    private func getAvailableStorage() -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            if let resourceValues = try? url.resourceValues(forKeys: [.volumeAvailableCapacityKey]) {
                if let availableCapacity = resourceValues.volumeAvailableCapacity {
                    return ByteCountFormatter.string(fromByteCount: Int64(availableCapacity), countStyle: .file)
                }
            }
        }
        return "Unknown"
    }
    
    private func getUsedStorage() -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            if let resourceValues = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey]) {
                if let totalCapacity = resourceValues.volumeTotalCapacity,
                   let availableCapacity = resourceValues.volumeAvailableCapacity {
                    let usedCapacity = totalCapacity - availableCapacity
                    return ByteCountFormatter.string(fromByteCount: Int64(usedCapacity), countStyle: .file)
                }
            }
        }
        return "Unknown"
    }
    
    private func getStorageUsagePercentage() -> Double {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            if let resourceValues = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey]) {
                if let totalCapacity = resourceValues.volumeTotalCapacity,
                   let availableCapacity = resourceValues.volumeAvailableCapacity {
                    let usedCapacity = totalCapacity - availableCapacity
                    return Double(usedCapacity) / Double(totalCapacity)
                }
            }
        }
        return 0.0
    }
}