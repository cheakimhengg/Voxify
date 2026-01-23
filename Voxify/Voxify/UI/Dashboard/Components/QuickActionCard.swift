import SwiftUI

/// A card showing quick actions or hotkey hints
struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let hotkey: String?

    init(
        title: String,
        subtitle: String,
        icon: String,
        hotkey: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.hotkey = hotkey
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.accentColor)
            }

            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))

                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Hotkey badge
            if let hotkey = hotkey {
                HotkeyBadge(text: hotkey)
            }
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

/// Badge displaying a keyboard shortcut
private struct HotkeyBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(NSColor.separatorColor).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    VStack(spacing: 8) {
        QuickActionCard(
            title: "Voice Insert",
            subtitle: "Hold to record and insert text",
            icon: "mic.fill",
            hotkey: "Hold Ctrl"
        )
        QuickActionCard(
            title: "Free Hand Mode",
            subtitle: "Continuous dictation until stopped",
            icon: "waveform",
            hotkey: "Ctrl+Shift"
        )
    }
    .padding()
    .frame(width: 350)
}
