import SwiftUI

/// Home dashboard showing stats, activity, and quick actions
struct HomeDashboardView: View {
    @State private var statistics: HistoryStatistics?
    @State private var recentEntries: [DictationHistoryEntry] = []
    @State private var todayWordCount: Int = 0

    private let historyStore = HistoryStore()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Welcome header
                welcomeHeader

                // Stats grid
                statsGrid

                // Two-column layout for chart and quick actions
                HStack(alignment: .top, spacing: 20) {
                    // Weekly activity chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Activity")
                            .font(.system(size: 14, weight: .semibold))

                        WeeklyActivityChart(dailyCounts: statistics?.dailyWordCounts ?? [:])
                            .frame(height: 160)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(NSColor.controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Quick actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Start")
                            .font(.system(size: 14, weight: .semibold))

                        VStack(spacing: 8) {
                            QuickActionCard(
                                title: "Voice Insert",
                                subtitle: "Hold to record and insert text",
                                icon: "mic.fill",
                                hotkey: "Hold Ctrl"
                            )
                            QuickActionCard(
                                title: "Free Hand Mode",
                                subtitle: "Continuous dictation",
                                icon: "waveform",
                                hotkey: "Ctrl+Shift"
                            )
                        }
                    }
                    .frame(width: 280)
                }

                // Recent dictations
                if !recentEntries.isEmpty {
                    recentDictationsSection
                }
            }
            .padding(24)
        }
        .onAppear {
            loadData()
        }
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.system(size: 28, weight: .bold))

            Text("Speak naturally, write perfectly \u{2013} in any app.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Hello"
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                icon: "text.word.spacing",
                value: formatNumber(statistics?.totalWords ?? 0),
                label: "Total Words",
                iconColor: .blue
            )
            StatCard(
                icon: "waveform",
                value: "\(statistics?.totalEntries ?? 0)",
                label: "Sessions",
                iconColor: .purple
            )
            StatCard(
                icon: "clock.arrow.circlepath",
                value: formatMinutes(statistics?.estimatedTimeSavedMinutes ?? 0),
                label: "Time Saved",
                iconColor: .green
            )
            StatCard(
                icon: "calendar",
                value: formatNumber(todayWordCount),
                label: "Today's Words",
                iconColor: .orange
            )
        }
    }

    // MARK: - Recent Dictations

    private var recentDictationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Dictations")
                    .font(.system(size: 14, weight: .semibold))

                Spacer()

                // This would navigate to history - handled by parent
            }

            VStack(spacing: 8) {
                ForEach(recentEntries.prefix(3)) { entry in
                    RecentDictationRow(entry: entry)
                }
            }
        }
    }

    // MARK: - Helpers

    private func loadData() {
        statistics = historyStore.statistics()
        recentEntries = Array(historyStore.load().prefix(3))
        todayWordCount = historyStore.todayEntries().reduce(0) { $0 + $1.wordCount }
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fk", Double(number) / 1000)
        }
        return "\(number)"
    }

    private func formatMinutes(_ minutes: Double) -> String {
        if minutes < 1 {
            return "0 min"
        } else if minutes < 60 {
            return "\(Int(minutes)) min"
        } else {
            let hours = Int(minutes / 60)
            let mins = Int(minutes.truncatingRemainder(dividingBy: 60))
            if mins == 0 {
                return "\(hours) hr"
            }
            return "\(hours)h \(mins)m"
        }
    }
}

#Preview {
    HomeDashboardView()
        .frame(width: 700, height: 600)
}
