import Foundation

struct DictionaryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var term: String
    var languageCode: String
    var pronunciationHint: String?
    var createdAt: Date
    var isEnabled: Bool
}

final class DictionaryStore {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "voxify.dictionary.store")

    init(fileManager: FileManager = .default) {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let folder = (base ?? fileManager.homeDirectoryForCurrentUser)
            .appendingPathComponent("Voxify", isDirectory: true)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        self.fileURL = folder.appendingPathComponent("dictionary.json")
    }

    init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        let folder = fileURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    func load() -> [DictionaryEntry] {
        queue.sync { loadUnlocked() }
    }

    func add(term: String, languageCode: String, pronunciationHint: String? = nil, isEnabled: Bool = true) -> DictionaryEntry {
        let entry = DictionaryEntry(
            id: UUID(),
            term: term,
            languageCode: languageCode,
            pronunciationHint: pronunciationHint,
            createdAt: Date(),
            isEnabled: isEnabled
        )
        queue.sync {
            var entries = loadUnlocked()
            entries.append(entry)
            saveUnlocked(entries)
        }
        return entry
    }

    func update(_ entry: DictionaryEntry) {
        queue.sync {
            var entries = loadUnlocked()
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index] = entry
                saveUnlocked(entries)
            }
        }
    }

    func remove(id: UUID) {
        queue.sync {
            var entries = loadUnlocked()
            entries.removeAll { $0.id == id }
            saveUnlocked(entries)
        }
    }

    private func loadUnlocked() -> [DictionaryEntry] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        return (try? JSONDecoder().decode([DictionaryEntry].self, from: data)) ?? []
    }

    private func saveUnlocked(_ entries: [DictionaryEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else {
            return
        }
        try? data.write(to: fileURL, options: .atomic)
    }
}
