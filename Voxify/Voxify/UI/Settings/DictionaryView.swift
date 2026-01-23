import SwiftUI

struct DictionaryView: View {
    @State private var entries: [DictionaryEntry] = []
    @State private var term = ""
    @State private var languageCode = "en-US"

    private let store = DictionaryStore()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Dictionary")
                .font(.headline)

            HStack {
                TextField("Term", text: $term)
                TextField("Language", text: $languageCode)
                Button("Add") {
                    addEntry()
                }
                .disabled(term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

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
        .padding(16)
        .onAppear(perform: load)
        .frame(minWidth: 420, minHeight: 320)
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
