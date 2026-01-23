import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            DictionaryView()
                .tabItem {
                    Label("Dictionary", systemImage: "book.closed")
                }
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            CommandHelpView()
                .tabItem {
                    Label("Commands", systemImage: "command")
                }
            UsageView()
                .tabItem {
                    Label("Usage", systemImage: "chart.bar")
                }
        }
        .frame(minWidth: 680, minHeight: 520)
        .padding(8)
    }
}
