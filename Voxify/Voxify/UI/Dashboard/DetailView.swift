import SwiftUI

/// Routes the selected navigation item to the appropriate view
struct DetailView: View {
    let selectedItem: NavigationItem

    var body: some View {
        Group {
            switch selectedItem {
            case .home:
                HomeDashboardView()
            case .history:
                HistoryView()
            case .dictionary:
                DictionaryView()
            case .settings:
                DashboardSettingsView()
            case .information:
                InformationView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}

#Preview {
    DetailView(selectedItem: .home)
        .frame(width: 700, height: 600)
}
