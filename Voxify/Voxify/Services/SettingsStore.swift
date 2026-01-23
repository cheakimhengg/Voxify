import Foundation

struct VoxifySettings: Codable, Equatable {
    var hotkey: String?
    var holdToTalkEnabled: Bool
    var continuousModeEnabled: Bool
    var pauseThresholdSeconds: Double
    var silenceThreshold: Float
    var beepEnabled: Bool
    var languageHint: String?
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

    static let `default` = VoxifySettings(
        hotkey: "Right Command",
        holdToTalkEnabled: true,
        continuousModeEnabled: false,
        pauseThresholdSeconds: 3.5,
        silenceThreshold: 0.02,
        beepEnabled: true,
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
        saveHistoryEnabled: true
    )
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
        return (try? JSONDecoder().decode(VoxifySettings.self, from: data)) ?? .default
    }

    func save(_ settings: VoxifySettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }
        defaults.set(data, forKey: settingsKey)
    }

    func update(_ mutate: (inout VoxifySettings) -> Void) {
        var current = load()
        mutate(&current)
        save(current)
    }
}
