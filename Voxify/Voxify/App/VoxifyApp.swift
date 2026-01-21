import AppKit
import SwiftUI

@main
struct VoxifyApp: App {
    @StateObject private var menuBarController = MenuBarController()

    var body: some Scene {
        MenuBarExtra("Voxify", systemImage: "waveform") {
            Button(menuBarController.isDictating ? "Stop Dictation" : "Start Dictation") {
                menuBarController.toggleDictation()
            }

            DictationOverlayView(viewModel: menuBarController.viewModel)

            Divider()
            Button("Settings") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.window)
        Settings {
            SettingsView()
        }
    }
}
