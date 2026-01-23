import AppKit

/// Monitors global hotkeys for dictation control
/// - Ctrl hold: Start recording, release to stop and insert
/// - Ctrl+Shift: Toggle free hand (continuous) mode
final class HotkeyMonitor {
    private var flagsMonitor: Any?
    private var isCtrlHeld = false
    private var wasCtrlShift = false

    var onHoldStart: (() -> Void)?
    var onHoldEnd: (() -> Void)?
    var onToggleContinuous: (() -> Void)?

    func start() {
        stop()
        flagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged]) { [weak self] event in
            self?.handle(event)
        }
    }

    func stop() {
        if let flagsMonitor {
            NSEvent.removeMonitor(flagsMonitor)
        }
        flagsMonitor = nil
        isCtrlHeld = false
        wasCtrlShift = false
    }

    private func handle(_ event: NSEvent) {
        let hasCtrl = event.modifierFlags.contains(.control)
        let hasShift = event.modifierFlags.contains(.shift)

        // Ctrl+Shift pressed - toggle continuous mode
        if hasCtrl && hasShift && !wasCtrlShift {
            wasCtrlShift = true
            onToggleContinuous?()
            return
        }

        // Ctrl+Shift released
        if wasCtrlShift && (!hasCtrl || !hasShift) {
            wasCtrlShift = false
            // Don't trigger hold end if we were in Ctrl+Shift mode
            if !hasCtrl {
                isCtrlHeld = false
            }
            return
        }

        // Skip if we're in Ctrl+Shift mode
        if wasCtrlShift {
            return
        }

        // Ctrl pressed (without Shift) - start hold recording
        if hasCtrl && !hasShift && !isCtrlHeld {
            isCtrlHeld = true
            onHoldStart?()
            return
        }

        // Ctrl released - stop hold recording
        if !hasCtrl && isCtrlHeld {
            isCtrlHeld = false
            onHoldEnd?()
            return
        }
    }
}
