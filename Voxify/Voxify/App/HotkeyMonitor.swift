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
    private var holdKeyCode: UInt16? = nil

    // Track pressed modifier-only hotkey to avoid repeat triggers
    private var activeModifierHotkey: String? = nil

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
        print("  Hold-to-talk: \(holdToTalkHotkey.readableString) (keyCode: \(String(describing: holdToTalkHotkey.keyCode)), modifiers: \(holdToTalkHotkey.modifiers))")
        print("  Hands-free: \(handsFreeHotkey.readableString) (keyCode: \(String(describing: handsFreeHotkey.keyCode)), modifiers: \(handsFreeHotkey.modifiers))")
        print("  TTS: \(ttsHotkey.readableString) (keyCode: \(String(describing: ttsHotkey.keyCode)), modifiers: \(ttsHotkey.modifiers))")
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
        holdKeyCode = nil
        activeModifierHotkey = nil
    }

    // MARK: - Event Handlers

    private func handleKeyDown(_ event: NSEvent) {
        // Ignore repeat events (key held down)
        if event.isARepeat { return }

        let keyCode = event.keyCode
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Check hold-to-talk (key-based)
        if let holdKeyCode = holdToTalkHotkey.keyCode {
            if keyCode == holdKeyCode && matchesModifiers(holdToTalkHotkey, modifiers) {
                if !isHoldActive {
                    self.holdKeyCode = keyCode
                    isHoldActive = true
                    print("[HotkeyMonitor] Hold-to-talk started (key: \(keyCode))")
                    onHoldStart?()
                }
                return
            }
        }

        // Check hands-free toggle (key-based)
        if let hfKeyCode = handsFreeHotkey.keyCode {
            if keyCode == hfKeyCode && matchesModifiers(handsFreeHotkey, modifiers) {
                print("[HotkeyMonitor] Hands-free toggled (key: \(keyCode))")
                onToggleContinuous?()
                return
            }
        }

        // Check TTS toggle (key-based)
        if let ttsKeyCode = ttsHotkey.keyCode {
            if keyCode == ttsKeyCode && matchesModifiers(ttsHotkey, modifiers) {
                print("[HotkeyMonitor] TTS triggered (key: \(keyCode))")
                onToggleTTS?()
                return
            }
        }

        // Check translate toggle (key-based)
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
        if let holdKey = holdKeyCode, keyCode == holdKey {
            holdKeyCode = nil
            if isHoldActive {
                isHoldActive = false
                print("[HotkeyMonitor] Hold-to-talk ended (key released: \(keyCode))")
                onHoldEnd?()
            }
            return
        }
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Handle modifier-only hotkeys (no keyCode set)

        // Hold-to-talk (modifier-only)
        if holdToTalkHotkey.keyCode == nil && !holdToTalkHotkey.modifiers.isEmpty {
            let matches = holdToTalkHotkey.matchesModifiers(modifiers)

            if matches && !isHoldActive {
                isHoldActive = true
                activeModifierHotkey = "holdToTalk"
                print("[HotkeyMonitor] Hold-to-talk started (modifiers: \(holdToTalkHotkey.modifiers))")
                onHoldStart?()
                return
            } else if !matches && isHoldActive && activeModifierHotkey == "holdToTalk" {
                isHoldActive = false
                activeModifierHotkey = nil
                print("[HotkeyMonitor] Hold-to-talk ended (modifiers released)")
                onHoldEnd?()
                return
            }
        }

        // Hands-free toggle (modifier-only)
        if handsFreeHotkey.keyCode == nil && !handsFreeHotkey.modifiers.isEmpty {
            let matches = handsFreeHotkey.matchesModifiers(modifiers)

            if matches && activeModifierHotkey == nil {
                // Don't trigger if hold-to-talk is active with same modifiers
                if !(holdToTalkHotkey.keyCode == nil && holdToTalkHotkey.matchesModifiers(modifiers)) {
                    activeModifierHotkey = "handsFree"
                    print("[HotkeyMonitor] Hands-free toggled (modifiers: \(handsFreeHotkey.modifiers))")
                    onToggleContinuous?()
                    return
                }
            } else if !matches && activeModifierHotkey == "handsFree" {
                activeModifierHotkey = nil
            }
        }

        // TTS toggle (modifier-only)
        if ttsHotkey.keyCode == nil && !ttsHotkey.modifiers.isEmpty {
            let matches = ttsHotkey.matchesModifiers(modifiers)

            if matches && activeModifierHotkey == nil {
                activeModifierHotkey = "tts"
                print("[HotkeyMonitor] TTS triggered (modifiers: \(ttsHotkey.modifiers))")
                onToggleTTS?()
                return
            } else if !matches && activeModifierHotkey == "tts" {
                activeModifierHotkey = nil
            }
        }

        // Translate toggle (modifier-only)
        if translateHotkey.keyCode == nil && !translateHotkey.modifiers.isEmpty {
            let matches = translateHotkey.matchesModifiers(modifiers)

            if matches && activeModifierHotkey == nil {
                activeModifierHotkey = "translate"
                print("[HotkeyMonitor] Translate toggled (modifiers: \(translateHotkey.modifiers))")
                onToggleTranslate?()
                return
            } else if !matches && activeModifierHotkey == "translate" {
                activeModifierHotkey = nil
            }
        }
    }

    // MARK: - Helpers

    /// Check if event modifiers match the hotkey config
    private func matchesModifiers(_ config: HotkeyConfig, _ eventModifiers: NSEvent.ModifierFlags) -> Bool {
        // If no modifiers required, make sure no modifiers are pressed (for single key hotkeys)
        if config.modifiers.isEmpty {
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
