import Foundation

/// Represents a single dictation history entry
struct DictationHistoryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let rawText: String
    let polishedText: String
    let appBundleId: String
    let wordCount: Int
    let durationSeconds: TimeInterval

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        rawText: String,
        polishedText: String,
        appBundleId: String,
        durationSeconds: TimeInterval
    ) {
        self.id = id
        self.timestamp = timestamp
        self.rawText = rawText
        self.polishedText = polishedText
        self.appBundleId = appBundleId
        self.wordCount = polishedText.split { $0.isWhitespace || $0.isNewline }.count
        self.durationSeconds = durationSeconds
    }

    /// Formatted time string for display
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    /// Formatted relative time (e.g., "2 hours ago")
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

/// Manages dictation history storage and retrieval
final class HistoryStore {
    private let fileURL: URL
    private let maxEntries: Int
    private var cache: [DictationHistoryEntry]?

    init(maxEntries: Int = 1000) {
        self.maxEntries = maxEntries

        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let voxifyDir = appSupport.appendingPathComponent("Voxify", isDirectory: true)

        // Create directory if needed
        try? FileManager.default.createDirectory(at: voxifyDir, withIntermediateDirectories: true)

        self.fileURL = voxifyDir.appendingPathComponent("history.json")
    }

    // MARK: - Public API

    /// Load all history entries
    func load() -> [DictationHistoryEntry] {
        if let cache = cache {
            return cache
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let entries = try JSONDecoder().decode([DictationHistoryEntry].self, from: data)
            cache = entries
            return entries
        } catch {
            print("Failed to load history: \(error)")
            return []
        }
    }

    /// Add a new history entry
    func add(
        rawText: String,
        polishedText: String,
        appBundleId: String,
        durationSeconds: TimeInterval
    ) {
        var entries = load()

        let entry = DictationHistoryEntry(
            rawText: rawText,
            polishedText: polishedText,
            appBundleId: appBundleId,
            durationSeconds: durationSeconds
        )

        entries.insert(entry, at: 0)

        // Trim to max entries
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }

        save(entries)
    }

    /// Delete a specific entry
    func delete(_ entry: DictationHistoryEntry) {
        var entries = load()
        entries.removeAll { $0.id == entry.id }
        save(entries)
    }

    /// Delete multiple entries
    func delete(_ ids: Set<UUID>) {
        var entries = load()
        entries.removeAll { ids.contains($0.id) }
        save(entries)
    }

    /// Clear all history
    func clearAll() {
        save([])
    }

    /// Search history by text
    func search(query: String) -> [DictationHistoryEntry] {
        guard !query.isEmpty else { return load() }

        let lowercased = query.lowercased()
        return load().filter {
            $0.rawText.lowercased().contains(lowercased) ||
            $0.polishedText.lowercased().contains(lowercased)
        }
    }

    /// Get entries for a specific date range
    func entries(from startDate: Date, to endDate: Date) -> [DictationHistoryEntry] {
        load().filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
    }

    /// Get entries for a specific app
    func entries(forApp bundleId: String) -> [DictationHistoryEntry] {
        load().filter { $0.appBundleId == bundleId }
    }

    /// Get today's entries
    func todayEntries() -> [DictationHistoryEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return load().filter { $0.timestamp >= startOfDay }
    }

    /// Get total word count from history
    func totalWordCount() -> Int {
        load().reduce(0) { $0 + $1.wordCount }
    }

    /// Get statistics summary
    func statistics() -> HistoryStatistics {
        let entries = load()
        let totalWords = entries.reduce(0) { $0 + $1.wordCount }
        let totalDuration = entries.reduce(0.0) { $0 + $1.durationSeconds }

        // Group by app
        var appCounts: [String: Int] = [:]
        for entry in entries {
            appCounts[entry.appBundleId, default: 0] += entry.wordCount
        }

        // Group by day
        let calendar = Calendar.current
        var dailyCounts: [String: Int] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        for entry in entries {
            let key = dateFormatter.string(from: entry.timestamp)
            dailyCounts[key, default: 0] += entry.wordCount
        }

        return HistoryStatistics(
            totalEntries: entries.count,
            totalWords: totalWords,
            totalDurationSeconds: totalDuration,
            appWordCounts: appCounts,
            dailyWordCounts: dailyCounts
        )
    }

    // MARK: - Private

    private func save(_ entries: [DictationHistoryEntry]) {
        cache = entries

        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
}

/// Statistics derived from history
struct HistoryStatistics {
    let totalEntries: Int
    let totalWords: Int
    let totalDurationSeconds: TimeInterval
    let appWordCounts: [String: Int]
    let dailyWordCounts: [String: Int]

    /// Estimated time saved (assuming 45 WPM average typing speed)
    var estimatedTimeSavedMinutes: Double {
        Double(totalWords) / 45.0
    }

    /// Average words per dictation
    var averageWordsPerEntry: Double {
        guard totalEntries > 0 else { return 0 }
        return Double(totalWords) / Double(totalEntries)
    }

    /// Average dictation duration
    var averageDurationSeconds: TimeInterval {
        guard totalEntries > 0 else { return 0 }
        return totalDurationSeconds / Double(totalEntries)
    }

    /// Words per minute (dictation speed)
    var wordsPerMinute: Double {
        guard totalDurationSeconds > 0 else { return 0 }
        return Double(totalWords) / (totalDurationSeconds / 60.0)
    }
}
