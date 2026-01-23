import AppKit
import SwiftUI

@main
struct VoxifyApp: App {
    @StateObject private var menuBarController = MenuBarController()

    var body: some Scene {
        MenuBarExtra("Voxify", image: "MenuBarIcon") {
            VStack(alignment: .leading, spacing: 8) {
                // Status indicator
                HStack {
                    Circle()
                        .fill(menuBarController.isDictating ? Color.red : Color.gray)
                        .frame(width: 8, height: 8)
                    Text(menuBarController.isDictating ? "Recording..." : "Ready")
                        .font(.headline)
                }
                .padding(.bottom, 4)

                // Hotkey hints
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hold Ctrl - Voice Insert")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Ctrl+Shift - Free Hand Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                Button("Settings...") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }

                Button("Quit Voxify") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(12)
            .frame(width: 200)
        }
        .menuBarExtraStyle(.window)
        Settings {
            SettingsView()
        }
    }
}
