import Foundation

struct UsageStats: Codable {
    var totalWords: Int
    var totalSessions: Int
    var totalSeconds: TimeInterval
    var dailyWords: [String: Int]
    var appBreakdown: [String: Int]

    static let empty = UsageStats(totalWords: 0, totalSessions: 0, totalSeconds: 0, dailyWords: [:], appBreakdown: [:])
}

final class UsageStore {
    private let defaults: UserDefaults
    private let usageKey = "voxify.usage"
    private let dateFormatter: DateFormatter

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd"
        self.dateFormatter = formatter
    }

    func load() -> UsageStats {
        guard let data = defaults.data(forKey: usageKey),
              let decoded = try? JSONDecoder().decode(UsageStats.self, from: data) else {
            return .empty
        }
        return decoded
    }

    func save(_ stats: UsageStats) {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        defaults.set(data, forKey: usageKey)
    }

    func recordSession(words: Int, duration: TimeInterval, appBundleId: String) {
        var stats = load()
        stats.totalWords += words
        stats.totalSessions += 1
        stats.totalSeconds += duration

        let key = dateFormatter.string(from: Date())
        stats.dailyWords[key, default: 0] += words
        stats.appBreakdown[appBundleId, default: 0] += words

        save(stats)
    }
}
