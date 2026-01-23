import SwiftUI

/// A row displaying a recent dictation entry
struct RecentDictationRow: View {
    let entry: DictationHistoryEntry

    var body: some View {
        HStack(spacing: 12) {
            // App icon placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 36, height: 36)

                Image(systemName: "app.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.polishedText)
                    .font(.system(size: 13))
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(AppToneMapper.appName(for: entry.appBundleId))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Text("\u{2022}")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)

                    Text("\(entry.wordCount) words")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Time
            Text(entry.relativeTime)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    let entry = DictationHistoryEntry(
        rawText: "This is a sample dictation that was recorded earlier today.",
        polishedText: "This is a sample dictation that was recorded earlier today.",
        appBundleId: "com.apple.mail",
        durationSeconds: 5.2
    )

    return VStack(spacing: 8) {
        RecentDictationRow(entry: entry)
        RecentDictationRow(entry: entry)
    }
    .padding()
    .frame(width: 500)
}
