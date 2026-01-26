import SwiftUI

/// Main dashboard view with sidebar navigation
struct MainDashboardView: View {
    @State private var selectedItem: NavigationItem = .home
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showSettings = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selectedItem: $selectedItem, showSettings: $showSettings)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
        } detail: {
            DetailView(selectedItem: selectedItem)
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showSettings) {
            SettingsModalView(isPresented: $showSettings)
        }
    }
}

/// Modal wrapper for settings dialog
struct SettingsModalView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Color(NSColor.controlBackgroundColor))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(12)
            }
            .background(Color(NSColor.windowBackgroundColor))

            // Settings content
            DashboardSettingsView()
        }
        .frame(width: 780, height: 550)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    MainDashboardView()
        .frame(width: 900, height: 650)
}
