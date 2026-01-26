import SwiftUI

/// Information view showing about, shortcuts, commands, and credits
struct InformationView: View {
    @State private var language: String = SettingsStore().load().interfaceLanguage

    private var isKhmer: Bool { language == "Khmer" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(isKhmer ? "ព័ត៌មាន" : "Information")
                        .font(.system(size: 28, weight: .bold))

                    Text(isKhmer ? "ស្វែងយល់អំពី Voxify និងរបៀបប្រើប្រាស់។" : "Learn about Voxify and how to use it effectively.")
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
        .onReceive(NotificationCenter.default.publisher(for: .voxifySettingsDidChange)) { _ in
            language = SettingsStore().load().interfaceLanguage
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: isKhmer ? "អំពី Voxify" : "About Voxify", icon: "info.circle")

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

                    Text(isKhmer ? "កំណែ 1.0.0" : "Version 1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    Text(isKhmer ? "កម្មវិធីសរសេរដោយសំឡេងឥតគិតថ្លៃសម្រាប់ macOS" : "Free and open-source voice dictation for macOS")
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
            SectionHeader(title: isKhmer ? "ផ្លូវកាត់ក្តារចុច" : "Keyboard Shortcuts", icon: "keyboard")

            VStack(spacing: 0) {
                ShortcutRow(
                    shortcut: isKhmer ? "សង្កត់ Ctrl" : "Hold Ctrl",
                    description: isKhmer ? "សង្កត់ដើម្បីថត លែងដើម្បីបញ្ចូល" : "Voice Insert Mode - Hold to record, release to insert"
                )
                Divider()
                ShortcutRow(
                    shortcut: "Ctrl + Shift",
                    description: isKhmer ? "បើក/បិទរបៀបដោយស្វ័យប្រវត្តិ" : "Free Hand Mode - Toggle continuous dictation"
                )
                Divider()
                ShortcutRow(
                    shortcut: "Esc",
                    description: isKhmer ? "បោះបង់ការសរសេរបច្ចុប្បន្ន" : "Cancel current dictation"
                )
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Voice Commands

    private var voiceCommandsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: isKhmer ? "ពាក្យបញ្ជាសំឡេង" : "Voice Commands", icon: "mic")

            VStack(spacing: 0) {
                CommandRow(
                    command: "command: undo",
                    description: isKhmer ? "ត្រឡប់ការផ្លាស់ប្តូរចុងក្រោយ" : "Undo the last change"
                )
                Divider()
                CommandRow(
                    command: "command: redo",
                    description: isKhmer ? "ធ្វើវិញនូវការផ្លាស់ប្តូរចុងក្រោយ" : "Redo the last change"
                )
                Divider()
                CommandRow(
                    command: "command: new line",
                    description: isKhmer ? "បញ្ចូលបន្ទាត់ថ្មី" : "Insert a line break"
                )
                Divider()
                CommandRow(
                    command: "command: new paragraph",
                    description: isKhmer ? "បញ្ចូលកថាខណ្ឌថ្មី" : "Insert a paragraph break"
                )
                Divider()
                CommandRow(
                    command: "command: delete last sentence",
                    description: isKhmer ? "លុបប្រយោគចុងក្រោយ" : "Remove the most recent sentence"
                )
                Divider()
                CommandRow(
                    command: "command: format bullets",
                    description: isKhmer ? "ធ្វើទម្រង់ជាចំណុច" : "Format selection as bullets"
                )
                Divider()
                CommandRow(
                    command: "command: format numbered",
                    description: isKhmer ? "ធ្វើទម្រង់ជាលេខ" : "Format as numbered list"
                )
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Credits

    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: isKhmer ? "ប្រភពបើកចំហ" : "Open Source", icon: "heart")

            VStack(alignment: .leading, spacing: 16) {
                Text(isKhmer ? "Voxify គឺជាកម្មវិធីឥតគិតថ្លៃនិងប្រភពបើកចំហ។" : "Voxify is free and open-source software, built with love for the macOS community.")
                    .font(.system(size: 13))

                Text(isKhmer ? "អាចធ្វើបានដោយ:" : "Made possible by:")
                    .font(.system(size: 12, weight: .semibold))

                VStack(alignment: .leading, spacing: 8) {
                    CreditRow(name: "Whisper", description: isKhmer ? "ម៉ូដែលសម្គាល់សំឡេងរបស់ OpenAI" : "OpenAI's speech recognition model")
                    CreditRow(name: "SwiftUI", description: isKhmer ? "ក្របខ័ណ្ឌ UI របស់ Apple" : "Apple's declarative UI framework")
                    CreditRow(name: "macOS Accessibility APIs", description: isKhmer ? "សម្រាប់បញ្ចូលអត្ថបទ" : "For text insertion")
                }

                Divider()

                HStack(spacing: 8) {
                    Image(systemName: "star")
                        .foregroundColor(.yellow)
                    Text(isKhmer ? "ប្រសិនបើអ្នកចូលចិត្ត Voxify សូមផ្តល់ផ្កាយនៅ GitHub!" : "If you find Voxify useful, consider starring the project on GitHub!")
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
