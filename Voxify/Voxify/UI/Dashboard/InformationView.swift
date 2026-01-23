import SwiftUI

/// Information view showing about, shortcuts, commands, and credits
struct InformationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Information")
                        .font(.system(size: 28, weight: .bold))

                    Text("Learn about Voxify and how to use it effectively.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                // About section
                aboutSection

                // Keyboard shortcuts
                keyboardShortcutsSection

                // Voice commands
                voiceCommandsSection

                // Credits
                creditsSection
            }
            .padding(24)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "About Voxify", icon: "info.circle")

            HStack(spacing: 16) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Voxify")
                        .font(.system(size: 18, weight: .semibold))

                    Text("Version 1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    Text("Free and open-source voice dictation for macOS")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Keyboard Shortcuts

    private var keyboardShortcutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Keyboard Shortcuts", icon: "keyboard")

            VStack(spacing: 0) {
                ShortcutRow(
                    shortcut: "Hold Ctrl",
                    description: "Voice Insert Mode - Hold to record, release to insert"
                )
                Divider()
                ShortcutRow(
                    shortcut: "Ctrl + Shift",
                    description: "Free Hand Mode - Toggle continuous dictation"
                )
                Divider()
                ShortcutRow(
                    shortcut: "Esc",
                    description: "Cancel current dictation"
                )
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Voice Commands

    private var voiceCommandsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Voice Commands", icon: "mic")

            VStack(spacing: 0) {
                CommandRow(command: "command: undo", description: "Undo the last change")
                Divider()
                CommandRow(command: "command: redo", description: "Redo the last change")
                Divider()
                CommandRow(command: "command: new line", description: "Insert a line break")
                Divider()
                CommandRow(command: "command: new paragraph", description: "Insert a paragraph break")
                Divider()
                CommandRow(command: "command: delete last sentence", description: "Remove the most recent sentence")
                Divider()
                CommandRow(command: "command: format bullets", description: "Format selection as bullets")
                Divider()
                CommandRow(command: "command: format numbered", description: "Format as numbered list")
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Credits

    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Open Source", icon: "heart")

            VStack(alignment: .leading, spacing: 16) {
                Text("Voxify is free and open-source software, built with love for the macOS community.")
                    .font(.system(size: 13))

                Text("Made possible by:")
                    .font(.system(size: 12, weight: .semibold))

                VStack(alignment: .leading, spacing: 8) {
                    CreditRow(name: "Whisper", description: "OpenAI's speech recognition model")
                    CreditRow(name: "SwiftUI", description: "Apple's declarative UI framework")
                    CreditRow(name: "macOS Accessibility APIs", description: "For text insertion")
                }

                Divider()

                HStack(spacing: 8) {
                    Image(systemName: "star")
                        .foregroundColor(.yellow)
                    Text("If you find Voxify useful, consider starring the project on GitHub!")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Supporting Views

private struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.accentColor)

            Text(title)
                .font(.system(size: 14, weight: .semibold))
        }
    }
}

private struct ShortcutRow: View {
    let shortcut: String
    let description: String

    var body: some View {
        HStack {
            Text(shortcut)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.accentColor)
                .frame(width: 100, alignment: .leading)

            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(12)
    }
}

private struct CommandRow: View {
    let command: String
    let description: String

    var body: some View {
        HStack {
            Text(command)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 180, alignment: .leading)

            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(12)
    }
}

private struct CreditRow: View {
    let name: String
    let description: String

    var body: some View {
        HStack(spacing: 8) {
            Text("\u{2022}")
                .foregroundColor(.accentColor)

            Text(name)
                .font(.system(size: 12, weight: .medium))

            Text("-")
                .foregroundColor(.secondary)

            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    InformationView()
        .frame(width: 700, height: 700)
}
