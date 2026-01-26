import SwiftUI
import AppKit

/// View for browsing and managing dictation history
struct HistoryView: View {
    @State private var entries: [DictationHistoryEntry] = []
    @State private var searchQuery = ""
    @State private var selectedEntry: DictationHistoryEntry?
    @State private var showDeleteConfirmation = false
    @State private var language: String = SettingsStore().load().interfaceLanguage

    private let historyStore = HistoryStore()

    private var isKhmer: Bool { language == "Khmer" }

    var body: some View {
        VStack(spacing: 0) {
            // Search and actions bar
            toolbar

            Divider()

            if filteredEntries.isEmpty {
                emptyState
            } else {
                // History list
                historyList
            }
        }
        .onAppear {
            loadHistory()
        }
        .onReceive(NotificationCenter.default.publisher(for: .voxifySettingsDidChange)) { _ in
            language = SettingsStore().load().interfaceLanguage
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(isKhmer ? "ស្វែងរកប្រវត្តិ..." : "Search history...", text: $searchQuery)
                    .textFieldStyle(.plain)

                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Spacer()

            // Stats summary
            if !entries.isEmpty {
                HStack(spacing: 16) {
                    StatBadge(value: "\(totalWords)", label: isKhmer ? "ពាក្យ" : "words")
                    StatBadge(value: "\(entries.count)", label: isKhmer ? "ការសរសេរ" : "dictations")
                }
            }

            // Clear all button
            if !entries.isEmpty {
                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .help(isKhmer ? "សម្អាតប្រវត្តិទាំងអស់" : "Clear all history")
            }
        }
        .padding(12)
        .alert(isKhmer ? "សម្អាតប្រវត្តិ" : "Clear History", isPresented: $showDeleteConfirmation) {
            Button(isKhmer ? "បោះបង់" : "Cancel", role: .cancel) {}
            Button(isKhmer ? "សម្អាតទាំងអស់" : "Clear All", role: .destructive) {
                historyStore.clearAll()
                loadHistory()
            }
        } message: {
            Text(isKhmer ? "នេះនឹងលុបប្រវត្តិទាំងអស់។ សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។" : "This will permanently delete all dictation history. This action cannot be undone.")
        }
    }

    // MARK: - History List

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(groupedEntries, id: \.key) { dateKey, dayEntries in
                    Section {
                        ForEach(dayEntries) { entry in
                            HistoryEntryRow(entry: entry, isSelected: selectedEntry?.id == entry.id, isKhmer: isKhmer)
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        selectedEntry = selectedEntry?.id == entry.id ? nil : entry
                                    }
                                }
                                .contextMenu {
                                    Button(isKhmer ? "ចម្លងអត្ថបទ" : "Copy Text") {
                                        copyToClipboard(entry.polishedText)
                                    }
                                    Button(isKhmer ? "ចម្លងអត្ថបទដើម" : "Copy Original") {
                                        copyToClipboard(entry.rawText)
                                    }
                                    Divider()
                                    Button(isKhmer ? "លុប" : "Delete", role: .destructive) {
                                        historyStore.delete(entry)
                                        loadHistory()
                                    }
                                }
                        }
                    } header: {
                        Text(localizedDateKey(dateKey))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .padding(.top, 12)
                    }
                }
            }
            .padding(12)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(spacing: 4) {
                Text(searchQuery.isEmpty
                     ? (isKhmer ? "មិនទាន់មានប្រវត្តិ" : "No History Yet")
                     : (isKhmer ? "រកមិនឃើញលទ្ធផល" : "No Results"))
                    .font(.headline)
                Text(searchQuery.isEmpty
                     ? (isKhmer ? "ប្រវត្តិការសរសេររបស់អ្នកនឹងបង្ហាញនៅទីនេះ" : "Your dictation history will appear here")
                     : (isKhmer ? "សាកល្បងពាក្យស្វែងរកផ្សេង" : "Try a different search term"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Helpers

    private var filteredEntries: [DictationHistoryEntry] {
        if searchQuery.isEmpty {
            return entries
        }
        let query = searchQuery.lowercased()
        return entries.filter {
            $0.polishedText.lowercased().contains(query) ||
            $0.rawText.lowercased().contains(query)
        }
    }

    private var groupedEntries: [(key: String, value: [DictationHistoryEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry -> String in
            let calendar = Calendar.current

            if calendar.isDateInToday(entry.timestamp) {
                return "Today"
            } else if calendar.isDateInYesterday(entry.timestamp) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter.string(from: entry.timestamp)
            }
        }

        return grouped.sorted { $0.value.first?.timestamp ?? Date() > $1.value.first?.timestamp ?? Date() }
    }

    private func localizedDateKey(_ key: String) -> String {
        if isKhmer {
            switch key {
            case "Today": return "ថ្ងៃនេះ"
            case "Yesterday": return "ម្សិលមិញ"
            default: return key
            }
        }
        return key
    }

    private var totalWords: Int {
        filteredEntries.reduce(0) { $0 + $1.wordCount }
    }

    private func loadHistory() {
        entries = historyStore.load()
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

// MARK: - History Entry Row

private struct HistoryEntryRow: View {
    let entry: DictationHistoryEntry
    let isSelected: Bool
    let isKhmer: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                // App icon/name
                HStack(spacing: 6) {
                    Image(systemName: "app.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(AppToneMapper.appName(for: entry.appBundleId))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Time
                Text(entry.relativeTime)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            // Text content
            Text(entry.polishedText)
                .font(.system(size: 13))
                .lineLimit(isSelected ? nil : 2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Expanded details
            if isSelected {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()

                    // Original text (if different)
                    if entry.rawText != entry.polishedText {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(isKhmer ? "អត្ថបទដើម:" : "Original:")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(entry.rawText)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Stats
                    HStack(spacing: 16) {
                        Label(isKhmer ? "\(entry.wordCount) ពាក្យ" : "\(entry.wordCount) words", systemImage: "text.word.spacing")
                        Label(formatDuration(entry.durationSeconds), systemImage: "clock")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                    // Actions
                    HStack(spacing: 8) {
                        Button(isKhmer ? "ចម្លង" : "Copy") {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(entry.polishedText, forType: .string)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return isKhmer ? "\(Int(seconds)) វិនាទី" : "\(Int(seconds))s"
        } else {
            let minutes = Int(seconds / 60)
            let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
            return isKhmer ? "\(minutes) នាទី \(secs) វិនាទី" : "\(minutes)m \(secs)s"
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.system(size: 12, weight: .semibold))
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    HistoryView()
        .frame(width: 600, height: 500)
}
