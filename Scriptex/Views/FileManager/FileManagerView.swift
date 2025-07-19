import SwiftUI

struct FileManagerView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("File Manager")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.fileManager)
                    
                    Text("Browse and manage files")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("File management features coming soon...")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            Spacer()
        }
    }
}