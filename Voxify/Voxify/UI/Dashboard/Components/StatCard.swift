import SwiftUI

/// A card displaying a single statistic with icon and label
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color

    init(
        icon: String,
        value: String,
        label: String,
        iconColor: Color = .accentColor
    ) {
        self.icon = icon
        self.value = value
        self.label = label
        self.iconColor = iconColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)

            // Value and Label
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCard(
            icon: "text.word.spacing",
            value: "1,234",
            label: "Total Words",
            iconColor: .blue
        )
        StatCard(
            icon: "waveform",
            value: "42",
            label: "Sessions",
            iconColor: .purple
        )
    }
    .padding()
    .frame(width: 400)
}
