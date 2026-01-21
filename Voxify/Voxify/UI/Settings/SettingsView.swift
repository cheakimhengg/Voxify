import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            DictionaryView()
                .tabItem { Text("Dictionary") }
            CommandHelpView()
                .tabItem { Text("Commands") }
        }
        .frame(minWidth: 520, minHeight: 420)
        .padding(8)
    }
}
