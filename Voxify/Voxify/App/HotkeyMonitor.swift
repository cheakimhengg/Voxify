import AppKit
import Combine

/// Monitors global hotkeys for dictation control
/// Supports: single keys (F1), modifiers only (Ctrl), and combos (Ctrl+K)
final class HotkeyMonitor {
    private var flagsMonitor: Any?
    private var keyDownMonitor: Any?
    private var keyUpMonitor: Any?
    private var localFlagsMonitor: Any?
    private var localKeyDownMonitor: Any?
    private var localKeyUpMonitor: Any?

    private var holdToTalkHotkey: HotkeyConfig = .defaultHoldToTalk
    private var handsFreeHotkey: HotkeyConfig = .defaultHandsFree
    private var translateHotkey: HotkeyConfig = .defaultTranslate
    private var ttsHotkey: HotkeyConfig = .defaultTTS

    // Track state for hold-to-talk
    private var isHoldActive = false
    private var holdKeyPressed = false

    // Track state for toggle hotkeys (to prevent re-triggering)
    private var handsFreeTriggered = false
    private var translateTriggered = false
    private var ttsTriggered = false

    private let settingsStore: SettingsStore
    private var settingsObserver: NSObjectProtocol?

    var onHoldStart: (() -> Void)?
    var onHoldEnd: (() -> Void)?
    var onToggleContinuous: (() -> Void)?
    var onToggleTranslate: (() -> Void)?
    var onToggleTTS: (() -> Void)?

    init(settingsStore: SettingsStore = SettingsStore()) {
        self.settingsStore = settingsStore
        loadSettings()

        // Listen for settings changes
        settingsObserver = NotificationCenter.default.addObserver(
            forName: .voxifySettingsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadSettings()
        }
    }

    deinit {
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        stop()
    }

    /// Reload hotkey configurations from settings
    func loadSettings() {
        let settings = settingsStore.load()
        holdToTalkHotkey = settings.holdToTalkHotkey
        handsFreeHotkey = settings.handsFreeHotkey
        translateHotkey = settings.translateHotkey
        ttsHotkey = settings.ttsHotkey

        // Debug: print loaded hotkeys
        print("[HotkeyMonitor] Loaded hotkeys:")
        print("  Hold-to-talk: \(holdToTalkHotkey.readableString)")
        print("  Hands-free: \(handsFreeHotkey.readableString)")
        print("  TTS: \(ttsHotkey.readableString)")
    }

    func start() {
        stop()
        loadSettings()

        // Global monitors
        flagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
        }

        keyDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyDown(event)
        }

        keyUpMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyUp) { [weak self] event in
            self?.handleKeyUp(event)
        }

        // Local monitors (when app is focused)
        localFlagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
            return event
        }

        localKeyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyDown(event)
            return event
        }

        localKeyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [weak self] event in
            self?.handleKeyUp(event)
            return event
        }

        print("[HotkeyMonitor] Started monitoring")
    }

    func stop() {
        [flagsMonitor, keyDownMonitor, keyUpMonitor,
         localFlagsMonitor, localKeyDownMonitor, localKeyUpMonitor].forEach { monitor in
            if let m = monitor {
                NSEvent.removeMonitor(m)
            }
        }
        flagsMonitor = nil
        keyDownMonitor = nil
        keyUpMonitor = nil
        localFlagsMonitor = nil
        localKeyDownMonitor = nil
        localKeyUpMonitor = nil
        resetState()
    }

    private func resetState() {
        isHoldActive = false
        holdKeyPressed = false
        handsFreeTriggered = false
        translateTriggered = false
        ttsTriggered = false
    }

    // MARK: - Event Handlers

    private func handleKeyDown(_ event: NSEvent) {
        let keyCode = event.keyCode
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Check hold-to-talk (if it uses a key)
        if let holdKeyCode = holdToTalkHotkey.keyCode {
            if keyCode == holdKeyCode && matchesModifiers(holdToTalkHotkey, modifiers) {
                if !holdKeyPressed {
                    holdKeyPressed = true
                    isHoldActive = true
                    print("[HotkeyMonitor] Hold-to-talk started (key: \(keyCode))")
                    onHoldStart?()
                }
                return
            }
        }

        // Check hands-free toggle (if it uses a key)
        if let hfKeyCode = handsFreeHotkey.keyCode {
            if keyCode == hfKeyCode && matchesModifiers(handsFreeHotkey, modifiers) {
                print("[HotkeyMonitor] Hands-free toggled (key: \(keyCode))")
                onToggleContinuous?()
                return
            }
        }

        // Check TTS toggle (if it uses a key)
        if let ttsKeyCode = ttsHotkey.keyCode {
            if keyCode == ttsKeyCode && matchesModifiers(ttsHotkey, modifiers) {
                print("[HotkeyMonitor] TTS toggled (key: \(keyCode))")
                onToggleTTS?()
                return
            }
        }

        // Check translate toggle (if it uses a key)
        if let transKeyCode = translateHotkey.keyCode {
            if keyCode == transKeyCode && matchesModifiers(translateHotkey, modifiers) {
                print("[HotkeyMonitor] Translate toggled (key: \(keyCode))")
                onToggleTranslate?()
                return
            }
        }
    }

    private func handleKeyUp(_ event: NSEvent) {
        let keyCode = event.keyCode

        // Check if hold-to-talk key was released
        if let holdKeyCode = holdToTalkHotkey.keyCode {
            if keyCode == holdKeyCode && holdKeyPressed {
                holdKeyPressed = false
                if isHoldActive {
                    isHoldActive = false
                    print("[HotkeyMonitor] Hold-to-talk ended (key released: \(keyCode))")
                    onHoldEnd?()
                }
                return
            }
        }
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Only handle modifier-only hotkeys here (no keyCode)
        handleModifierOnlyHotkeys(modifiers)
    }

    private func handleModifierOnlyHotkeys(_ modifiers: NSEvent.ModifierFlags) {
        // Hold-to-talk (modifier-only)
        if holdToTalkHotkey.keyCode == nil && !holdToTalkHotkey.modifiers.isEmpty {
            let matches = holdToTalkHotkey.matchesModifiers(modifiers)

            if matches && !isHoldActive {
                // Check if this would also match hands-free (avoid conflict)
                let hfMatches = handsFreeHotkey.keyCode == nil && handsFreeHotkey.matchesModifiers(modifiers)
                if !hfMatches {
                    isHoldActive = true
                    print("[HotkeyMonitor] Hold-to-talk started (modifiers)")
                    onHoldStart?()
                    return
                }
            } else if !matches && isHoldActive {
                isHoldActive = false
                print("[HotkeyMonitor] Hold-to-talk ended (modifiers released)")
                onHoldEnd?()
                return
            }
        }

        // Hands-free toggle (modifier-only)
        if handsFreeHotkey.keyCode == nil && !handsFreeHotkey.modifiers.isEmpty {
            let matches = handsFreeHotkey.matchesModifiers(modifiers)

            if matches && !handsFreeTriggered {
                handsFreeTriggered = true
                print("[HotkeyMonitor] Hands-free toggled (modifiers)")
                onToggleContinuous?()
                return
            } else if !matches && handsFreeTriggered {
                handsFreeTriggered = false
            }
        }

        // TTS toggle (modifier-only)
        if ttsHotkey.keyCode == nil && !ttsHotkey.modifiers.isEmpty {
            let matches = ttsHotkey.matchesModifiers(modifiers)

            if matches && !ttsTriggered {
                // Avoid conflicts
                let holdMatches = holdToTalkHotkey.keyCode == nil && holdToTalkHotkey.matchesModifiers(modifiers)
                let hfMatches = handsFreeHotkey.keyCode == nil && handsFreeHotkey.matchesModifiers(modifiers)
                if !holdMatches && !hfMatches {
                    ttsTriggered = true
                    print("[HotkeyMonitor] TTS toggled (modifiers)")
                    onToggleTTS?()
                    return
                }
            } else if !matches && ttsTriggered {
                ttsTriggered = false
            }
        }

        // Translate toggle (modifier-only)
        if translateHotkey.keyCode == nil && !translateHotkey.modifiers.isEmpty {
            let matches = translateHotkey.matchesModifiers(modifiers)

            if matches && !translateTriggered {
                let hfMatches = handsFreeHotkey.keyCode == nil && handsFreeHotkey.matchesModifiers(modifiers)
                if !hfMatches {
                    translateTriggered = true
                    print("[HotkeyMonitor] Translate toggled (modifiers)")
                    onToggleTranslate?()
                    return
                }
            } else if !matches && translateTriggered {
                translateTriggered = false
            }
        }
    }

    // MARK: - Helpers

    /// Check if event modifiers match the hotkey config
    private func matchesModifiers(_ config: HotkeyConfig, _ eventModifiers: NSEvent.ModifierFlags) -> Bool {
        // If no modifiers required, just return true
        if config.modifiers.isEmpty {
            // But make sure no modifiers are pressed (for single key hotkeys)
            return !eventModifiers.contains(.control) &&
                   !eventModifiers.contains(.option) &&
                   !eventModifiers.contains(.shift) &&
                   !eventModifiers.contains(.command)
        }

        // Check each required modifier
        let needsControl = config.modifiers.contains("control")
        let needsOption = config.modifiers.contains("option")
        let needsShift = config.modifiers.contains("shift")
        let needsCommand = config.modifiers.contains("command")

        let hasControl = eventModifiers.contains(.control)
        let hasOption = eventModifiers.contains(.option)
        let hasShift = eventModifiers.contains(.shift)
        let hasCommand = eventModifiers.contains(.command)

        // All required modifiers must be present
        if needsControl && !hasControl { return false }
        if needsOption && !hasOption { return false }
        if needsShift && !hasShift { return false }
        if needsCommand && !hasCommand { return false }

        return true
    }
}
