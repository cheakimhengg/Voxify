import SwiftUI

/// Home dashboard showing stats, activity, and quick actions
struct HomeDashboardView: View {
    @State private var statistics: HistoryStatistics?
    @State private var recentEntries: [DictationHistoryEntry] = []
    @State private var todayWordCount: Int = 0
    @State private var language: String = SettingsStore().load().interfaceLanguage
    @State private var settings: VoxifySettings = SettingsStore().load()

    private let historyStore = HistoryStore()

    private var isKhmer: Bool { language == "Khmer" }

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
                        Text(isKhmer ? "សកម្មភាពប្រចាំសប្តាហ៍" : "Weekly Activity")
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
                        Text(isKhmer ? "ចាប់ផ្តើមរហ័ស" : "Quick Start")
                            .font(.system(size: 14, weight: .semibold))

                        VStack(spacing: 8) {
                            QuickActionCard(
                                title: isKhmer ? "បញ្ចូលសំឡេង" : "Voice Insert",
                                subtitle: isKhmer ? "សង្កត់ដើម្បីថតនិងបញ្ចូលអត្ថបទ" : "Hold to record and insert text",
                                icon: "mic.fill",
                                hotkey: settings.holdToTalkHotkey.readableString
                            )
                            QuickActionCard(
                                title: isKhmer ? "របៀបស្វ័យប្រវត្តិ" : "Free Hand Mode",
                                subtitle: isKhmer ? "សរសេរដោយស្វ័យប្រវត្តិ" : "Continuous dictation",
                                icon: "waveform",
                                hotkey: settings.handsFreeHotkey.readableString
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
        .onReceive(NotificationCenter.default.publisher(for: .voxifySettingsDidChange)) { _ in
            settings = SettingsStore().load()
            language = settings.interfaceLanguage
        }
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.system(size: 28, weight: .bold))

            Text(isKhmer ? "និយាយធម្មតា សរសេរល្អឥតខ្ចោះ \u{2013} ក្នុងកម្មវិធីណាមួយ។" : "Speak naturally, write perfectly \u{2013} in any app.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if isKhmer {
            switch hour {
            case 5..<12: return "អរុណសួស្តី"
            case 12..<17: return "ទិវាសួស្តី"
            case 17..<22: return "សាយ័ណសួស្តី"
            default: return "សួស្តី"
            }
        } else {
            switch hour {
            case 5..<12: return "Good morning"
            case 12..<17: return "Good afternoon"
            case 17..<22: return "Good evening"
            default: return "Hello"
            }
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
                label: isKhmer ? "ពាក្យសរុប" : "Total Words",
                iconColor: .blue
            )
            StatCard(
                icon: "waveform",
                value: "\(statistics?.totalEntries ?? 0)",
                label: isKhmer ? "វគ្គ" : "Sessions",
                iconColor: .purple
            )
            StatCard(
                icon: "clock.arrow.circlepath",
                value: formatMinutes(statistics?.estimatedTimeSavedMinutes ?? 0),
                label: isKhmer ? "ពេលសន្សំ" : "Time Saved",
                iconColor: .green
            )
            StatCard(
                icon: "calendar",
                value: formatNumber(todayWordCount),
                label: isKhmer ? "ពាក្យថ្ងៃនេះ" : "Today's Words",
                iconColor: .orange
            )
        }
    }

    // MARK: - Recent Dictations

    private var recentDictationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isKhmer ? "ការសរសេរថ្មីៗ" : "Recent Dictations")
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
