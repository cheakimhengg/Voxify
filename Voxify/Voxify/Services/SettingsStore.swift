import AppKit
import Carbon.HIToolbox
import Foundation

/// Represents a keyboard shortcut with modifier keys and an optional key code
struct HotkeyConfig: Codable, Equatable {
    var modifiers: [String]  // e.g., ["control"], ["control", "shift"], ["option", "command"]
    var keyCode: UInt16?     // Optional: for regular keys (not just modifiers)
    var keyChar: String?     // Display character for the key

    /// Display string for the hotkey (e.g., "⌃⇧K" or "⌃")
    var displayString: String {
        var parts: [String] = []
        if modifiers.contains("control") { parts.append("⌃") }
        if modifiers.contains("option") { parts.append("⌥") }
        if modifiers.contains("shift") { parts.append("⇧") }
        if modifiers.contains("command") { parts.append("⌘") }
        if modifiers.contains("fn") { parts.append("fn") }
        if let char = keyChar, !char.isEmpty {
            parts.append(char.uppercased())
        }
        return parts.joined()
    }

    /// Readable display string (e.g., "Ctrl+Shift+K")
    var readableString: String {
        var parts: [String] = []
        if modifiers.contains("control") { parts.append("Ctrl") }
        if modifiers.contains("option") { parts.append("Option") }
        if modifiers.contains("shift") { parts.append("Shift") }
        if modifiers.contains("command") { parts.append("Cmd") }
        if modifiers.contains("fn") { parts.append("Fn") }
        if let char = keyChar, !char.isEmpty {
            parts.append(char.uppercased())
        }
        return parts.joined(separator: "+")
    }

    /// Check if event modifiers match this config
    func matchesModifiers(_ eventModifiers: NSEvent.ModifierFlags) -> Bool {
        let hasControl = modifiers.contains("control")
        let hasOption = modifiers.contains("option")
        let hasShift = modifiers.contains("shift")
        let hasCommand = modifiers.contains("command")

        return eventModifiers.contains(.control) == hasControl &&
               eventModifiers.contains(.option) == hasOption &&
               eventModifiers.contains(.shift) == hasShift &&
               eventModifiers.contains(.command) == hasCommand
    }

    /// Check if event modifiers contain at least this config's modifiers
    func modifiersActive(in eventModifiers: NSEvent.ModifierFlags) -> Bool {
        if modifiers.contains("control") && !eventModifiers.contains(.control) { return false }
        if modifiers.contains("option") && !eventModifiers.contains(.option) { return false }
        if modifiers.contains("shift") && !eventModifiers.contains(.shift) { return false }
        if modifiers.contains("command") && !eventModifiers.contains(.command) { return false }
        return true
    }

    /// Default hold-to-talk hotkey (Control)
    static let defaultHoldToTalk = HotkeyConfig(modifiers: ["control"], keyCode: nil, keyChar: nil)

    /// Default hands-free hotkey (Control+Shift)
    static let defaultHandsFree = HotkeyConfig(modifiers: ["control", "shift"], keyCode: nil, keyChar: nil)

    /// Default translate mode hotkey (Control+Option)
    static let defaultTranslate = HotkeyConfig(modifiers: ["control", "option"], keyCode: nil, keyChar: nil)

    /// Default TTS hotkey (Command+Shift)
    static let defaultTTS = HotkeyConfig(modifiers: ["command", "shift"], keyCode: nil, keyChar: nil)
}

struct VoxifySettings: Codable, Equatable {
    // User profile
    var username: String

    // Hotkeys (legacy string format for backwards compatibility)
    var hotkey: String?
    var holdToTalkEnabled: Bool
    var continuousModeEnabled: Bool
    var handsFreeModeHotkey: String

    // New hotkey configs
    var holdToTalkHotkey: HotkeyConfig
    var handsFreeHotkey: HotkeyConfig
    var translateHotkey: HotkeyConfig
    var ttsHotkey: HotkeyConfig

    // Audio settings
    var pauseThresholdSeconds: Double
    var silenceThreshold: Float
    var beepEnabled: Bool

    // Language settings
    var interfaceLanguage: String
    var languageHint: String?

    // Polishing settings
    var polishingEnabled: Bool
    var autoRemoveFillers: Bool
    var repetitionDetection: Bool
    var grammarCorrection: Bool
    var autoFormatting: Bool
    var preferredTone: String
    var privacyMode: Bool
    var dailyWordGoal: Int

    // New Typeless-like features
    var midSentenceCorrectionEnabled: Bool
    var contextAwareToneEnabled: Bool
    var showAudioWaveform: Bool
    var saveHistoryEnabled: Bool

    // TTS settings
    var ttsEnabled: Bool
    var ttsVoice: String
    var ttsRate: Float

    static let `default` = VoxifySettings(
        username: "User",
        hotkey: "Ctrl",
        holdToTalkEnabled: true,
        continuousModeEnabled: false,
        handsFreeModeHotkey: "Ctrl+Shift",
        holdToTalkHotkey: .defaultHoldToTalk,
        handsFreeHotkey: .defaultHandsFree,
        translateHotkey: .defaultTranslate,
        ttsHotkey: .defaultTTS,
        pauseThresholdSeconds: 3.5,
        silenceThreshold: 0.02,
        beepEnabled: true,
        interfaceLanguage: "English",
        languageHint: nil,
        polishingEnabled: true,
        autoRemoveFillers: true,
        repetitionDetection: true,
        grammarCorrection: true,
        autoFormatting: true,
        preferredTone: "Professional",
        privacyMode: false,
        dailyWordGoal: 1000,
        midSentenceCorrectionEnabled: true,
        contextAwareToneEnabled: true,
        showAudioWaveform: true,
        saveHistoryEnabled: true,
        ttsEnabled: true,
        ttsVoice: "default",
        ttsRate: 0.5
    )
}

/// Notification posted when settings are saved
extension Notification.Name {
    static let voxifySettingsDidChange = Notification.Name("voxifySettingsDidChange")
}

final class SettingsStore {
    private let defaults: UserDefaults
    private let settingsKey = "voxify.settings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> VoxifySettings {
        guard let data = defaults.data(forKey: settingsKey) else {
            return .default
        }
        // Try to decode, but handle missing fields by merging with defaults
        do {
            return try JSONDecoder().decode(VoxifySettings.self, from: data)
        } catch {
            // If decoding fails (e.g., new fields added), return default
            return .default
        }
    }

    func save(_ settings: VoxifySettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }
        defaults.set(data, forKey: settingsKey)

        // Post notification so listeners can update
        NotificationCenter.default.post(name: .voxifySettingsDidChange, object: nil)
    }

    func update(_ mutate: (inout VoxifySettings) -> Void) {
        var current = load()
        mutate(&current)
        save(current)
    }

    /// Reset all settings to default values
    func resetToDefaults() {
        save(.default)
    }
}
