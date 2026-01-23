import AppKit
import SwiftUI

/// App delegate handling window management and dock behavior
final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Reopen the main window when clicking the dock icon
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // No visible windows, so open the dashboard
            for window in sender.windows {
                if window.identifier?.rawValue == "main-dashboard" {
                    window.makeKeyAndOrderFront(self)
                    return true
                }
            }
            // If no dashboard window found, create one by opening the app
            sender.windows.first?.makeKeyAndOrderFront(self)
        }
        return true
    }

    /// Keep app running even when all windows are closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app stays active in the background
        NSApp.setActivationPolicy(.regular)
    }
}
