import SwiftUI

struct DictionaryView: View {
    @State private var entries: [DictionaryEntry] = []
    @State private var term = ""
    @State private var languageCode = "en-US"
    @State private var language: String = SettingsStore().load().interfaceLanguage

    private let store = DictionaryStore()

    private var isKhmer: Bool { language == "Khmer" }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isKhmer ? "វចនានុក្រមផ្ទាល់ខ្លួន" : "Personal Dictionary")
                .font(.headline)

            HStack {
                TextField(isKhmer ? "ពាក្យ" : "Term", text: $term)
                TextField(isKhmer ? "ភាសា" : "Language", text: $languageCode)
                Button(isKhmer ? "បន្ថែម" : "Add") {
                    addEntry()
                }
                .disabled(term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "character.book.closed")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.5))

                    Text(isKhmer ? "មិនទាន់មានពាក្យ" : "No words yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(isKhmer ? "បន្ថែមពាក្យដែលអ្នកចង់ឱ្យ Voxify សម្គាល់" : "Add words you want Voxify to recognize")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(entries) { entry in
                        HStack {
                            Text(entry.term)
                            Spacer()
                            Text(entry.languageCode)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .padding(16)
        .onAppear(perform: load)
        .frame(minWidth: 420, minHeight: 320)
        .onReceive(NotificationCenter.default.publisher(for: .voxifySettingsDidChange)) { _ in
            language = SettingsStore().load().interfaceLanguage
        }
    }

    private func load() {
        entries = store.load()
    }

    private func addEntry() {
        _ = store.add(term: term, languageCode: languageCode)
        term = ""
        load()
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let entry = entries[index]
            store.remove(id: entry.id)
        }
        load()
    }
}
