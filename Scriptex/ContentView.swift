// MIT License
//
// Copyright (c) [2020-present] Alexis Bridoux
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UniformTypeIdentifiers
import SwiftUI

struct ContentView: View {
    @State private var selectedItem: SidebarItem = .dashboard
    @State private var networkInfo = NetworkInfo()
    @State private var systemInfo = SystemInfo()
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            SidebarView(selectedItem: $selectedItem)
            
            // Separator
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1)
            
            // Main Content
            DetailView(selectedItem: selectedItem, networkInfo: $networkInfo, systemInfo: $systemInfo)
        }
        .frame(minWidth: 1200, idealWidth: 1400, minHeight: 800, idealHeight: 900)
        .background(AppColors.mainBackground)
        .onAppear {
            updateSystemInfo()
        }
    }
}


extension ContentView {
    private func updateSystemInfo() {
        systemInfo = SystemInfo()
    }
    
    static func executeAsyncCommand(
        at path: [String],
        completion: @escaping (_ chunk: String, _ isLast: Bool, _ pid: Int32) -> ()
    ) {
        Task {
            do {
                try await ExecutionService.executeAsyncCommand(at: path, completion: completion)
            } catch {
                print("Failed to execute async command: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion("Error: \(error.localizedDescription)", true, 0)
                }
            }
        }
    }
}
