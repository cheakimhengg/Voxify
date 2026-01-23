import SwiftUI

struct UsageView: View {
    @State private var stats = UsageStore().load()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Productivity Insights")
                .font(.title2)

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Words Dictated")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(stats.totalWords)")
                        .font(.title3)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sessions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(stats.totalSessions)")
                        .font(.title3)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Time Saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timeSavedString())
                        .font(.title3)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("App Breakdown")
                    .font(.headline)
                ForEach(appBreakdown(), id: \.0) { app, words in
                    HStack {
                        Text(app)
                        Spacer()
                        Text("\(words) words")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .onAppear {
            stats = UsageStore().load()
        }
    }

    private func timeSavedString() -> String {
        let hours = stats.totalSeconds / 3600
        let saved = hours * 4
        return String(format: "%.1f hours", saved)
    }

    private func appBreakdown() -> [(String, Int)] {
        stats.appBreakdown
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
}
