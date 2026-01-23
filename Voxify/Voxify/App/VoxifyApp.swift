import AppKit
import SwiftUI

@main
struct VoxifyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarController = MenuBarController()

    var body: some Scene {
        // Main dashboard window
        WindowGroup {
            MainDashboardView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 900, height: 650)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        // Menu bar extra for quick access
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

                Button("Open Dashboard") {
                    openDashboard()
                }

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

    private func openDashboard() {
        // Activate the app and bring the main window to front
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.contentView?.subviews.first is NSHostingView<MainDashboardView> }) {
            window.makeKeyAndOrderFront(nil)
        } else if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
