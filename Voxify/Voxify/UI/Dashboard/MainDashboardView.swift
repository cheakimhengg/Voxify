import SwiftUI

/// Main dashboard view with sidebar navigation
struct MainDashboardView: View {
    @State private var selectedItem: NavigationItem = .home
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selectedItem: $selectedItem)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
        } detail: {
            DetailView(selectedItem: selectedItem)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    MainDashboardView()
        .frame(width: 900, height: 650)
}
