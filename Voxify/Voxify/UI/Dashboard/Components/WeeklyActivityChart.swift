import SwiftUI

/// Bar chart showing weekly dictation activity
struct WeeklyActivityChart: View {
    let dailyCounts: [String: Int]

    private var weekData: [(day: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        var data: [(String, Int)] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }
            let key = dateFormatter.string(from: date)
            let dayName = dayFormatter.string(from: date)
            let count = dailyCounts[key] ?? 0
            data.append((dayName, count))
        }

        return data
    }

    private var maxCount: Int {
        max(weekData.map(\.count).max() ?? 0, 1)
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 8) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(for: index))
                            .frame(
                                width: barWidth(for: geometry.size.width),
                                height: barHeight(for: item.count, maxHeight: geometry.size.height - 30)
                            )

                        // Day label
                        Text(item.day)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func barWidth(for totalWidth: CGFloat) -> CGFloat {
        let availableWidth = totalWidth - 48 // Account for spacing
        return max(availableWidth / 7 - 8, 20)
    }

    private func barHeight(for count: Int, maxHeight: CGFloat) -> CGFloat {
        guard count > 0 else { return 4 }
        let proportion = CGFloat(count) / CGFloat(maxCount)
        return max(proportion * maxHeight, 8)
    }

    private func barColor(for index: Int) -> Color {
        // Today is the last bar (index 6)
        if index == 6 {
            return .accentColor
        }
        return Color.accentColor.opacity(0.4)
    }
}

#Preview {
    let sampleData = [
        "2025-01-17": 150,
        "2025-01-18": 230,
        "2025-01-19": 80,
        "2025-01-20": 320,
        "2025-01-21": 190,
        "2025-01-22": 270,
        "2025-01-23": 140
    ]

    return WeeklyActivityChart(dailyCounts: sampleData)
        .frame(width: 300, height: 160)
        .padding()
}
