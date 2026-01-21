import Foundation

struct VoxifySettings: Codable {
    var hotkey: String?
    var languageHint: String?
    var polishingEnabled: Bool
    var preferredTone: String?

    static let `default` = VoxifySettings(hotkey: nil, languageHint: nil, polishingEnabled: true, preferredTone: nil)
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
