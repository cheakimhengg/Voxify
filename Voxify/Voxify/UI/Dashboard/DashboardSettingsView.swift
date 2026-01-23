import SwiftUI

/// Settings tab options
enum SettingsTab: String, CaseIterable, Identifiable {
    case account
    case settings
    case personalization
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .account: return "Account"
        case .settings: return "Settings"
        case .personalization: return "Personalization"
        case .about: return "About"
        }
    }

    var icon: String {
        switch self {
        case .account: return "person.circle"
        case .settings: return "gearshape"
        case .personalization: return "paintbrush"
        case .about: return "info.circle"
        }
    }
}

/// Settings view with tabbed sidebar matching Typeless design
struct DashboardSettingsView: View {
    @State private var selectedTab: SettingsTab = .account
    @State private var settings = SettingsStore().load()

    private let settingsStore = SettingsStore()

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            settingsSidebar
                .frame(width: 180)
                .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    tabContent
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        }
        .onChange(of: settings) { newValue in
            settingsStore.save(newValue)
        }
    }

    // MARK: - Sidebar

    private var settingsSidebar: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(SettingsTab.allCases) { tab in
                SettingsTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }

            Spacer()

            // External links
            Divider()
                .padding(.vertical, 8)

            ExternalLinkButton(title: "Help center", icon: "questionmark.circle")
            ExternalLinkButton(title: "Release notes", icon: "doc.text")
        }
        .padding(12)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .account:
            AccountTabView(settings: $settings)
        case .settings:
            SettingsTabView(settings: $settings)
        case .personalization:
            PersonalizationTabView(settings: $settings)
        case .about:
            AboutTabView()
        }
    }
}

// MARK: - Settings Tab Button

private struct SettingsTabButton: View {
    let tab: SettingsTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14))
                    .frame(width: 20)

                Text(tab.title)
                    .font(.system(size: 13))

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - External Link Button

private struct ExternalLinkButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 20)

                Text(title)
                    .font(.system(size: 13))

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Account Tab

private struct AccountTabView: View {
    @Binding var settings: VoxifySettings
    @State private var isEditingUsername = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            Text("Account")
                .font(.system(size: 24, weight: .bold))

            // Profile section
            VStack(alignment: .leading, spacing: 20) {
                // Username
                SettingsRow(title: "Username", description: "Your display name in the app") {
                    HStack {
                        if isEditingUsername {
                            TextField("Username", text: $settings.username)
                                .textFieldStyle(.plain)
                                .frame(width: 150)
                                .padding(6)
                                .background(Color(NSColor.controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .onSubmit {
                                    isEditingUsername = false
                                }

                            Button("Save") {
                                isEditingUsername = false
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        } else {
                            Text(settings.username)
                                .foregroundColor(.secondary)

                            Button("Edit") {
                                isEditingUsername = true
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }

                Divider()

                // App info
                SettingsRow(title: "Version", description: "Current app version") {
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                Divider()

                // Data
                SettingsRow(title: "Data", description: "Your dictation data is stored locally") {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.green)
                        Text("Private")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Privacy note
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("All your data stays on your device. Voxify is free and open-source.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Settings Tab

private struct SettingsTabView: View {
    @Binding var settings: VoxifySettings

    // Available hotkey options
    private let hotkeyOptions = ["Ctrl", "Fn", "Option", "Command", "Shift"]
    private let handsFreeOptions = ["Ctrl+Shift", "Fn+Space", "Option+Space", "Command+Shift", "Ctrl+Space"]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            Text("Settings")
                .font(.system(size: 24, weight: .bold))

            // Keyboard shortcuts section
            SettingsSection(title: "Keyboard shortcuts", icon: "keyboard") {
                VStack(spacing: 16) {
                    EditableShortcutRow(
                        title: "Dictation",
                        description: "Hold down to speak. Release to insert text.",
                        selection: Binding(
                            get: { settings.hotkey ?? "Ctrl" },
                            set: { settings.hotkey = $0 }
                        ),
                        options: hotkeyOptions
                    )

                    Divider()

                    EditableShortcutRow(
                        title: "Hands-free mode",
                        description: "Press once to start speaking without holding. Press again to stop.",
                        selection: $settings.handsFreeModeHotkey,
                        options: handsFreeOptions
                    )
                }
            }

            // Language section
            SettingsSection(title: "Language", icon: "globe") {
                VStack(spacing: 16) {
                    SettingsRow(title: "Interface language", description: "Choose the language used in the user interface.") {
                        Picker("", selection: $settings.interfaceLanguage) {
                            Text("English").tag("English")
                            Text("Spanish").tag("Spanish")
                            Text("French").tag("French")
                            Text("German").tag("German")
                            Text("Chinese").tag("Chinese")
                            Text("Japanese").tag("Japanese")
                            Text("Korean").tag("Korean")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                    }

                    Divider()

                    SettingsRow(title: "Speech recognition", description: "Language hint for better accuracy.") {
                        TextField("Auto-detect", text: Binding(
                            get: { settings.languageHint ?? "" },
                            set: { settings.languageHint = $0.isEmpty ? nil : $0 }
                        ))
                        .textFieldStyle(.plain)
                        .frame(width: 150)
                        .padding(6)
                        .background(Color(NSColor.controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }

            // Audio section
            SettingsSection(title: "Audio", icon: "speaker.wave.2") {
                VStack(spacing: 16) {
                    SettingsRow(title: "Beep on start/stop", description: "Play a sound when dictation starts and stops.") {
                        Toggle("", isOn: $settings.beepEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(title: "Show audio waveform", description: "Display animated waveform during recording.") {
                        Toggle("", isOn: $settings.showAudioWaveform)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(title: "Pause threshold", description: "Seconds of silence before auto-stopping.") {
                        HStack {
                            TextField("", value: $settings.pauseThresholdSeconds, format: .number)
                                .textFieldStyle(.plain)
                                .frame(width: 60)
                                .padding(6)
                                .background(Color(NSColor.controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            Text("sec")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Personalization Tab

private struct PersonalizationTabView: View {
    @Binding var settings: VoxifySettings

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            Text("Personalization")
                .font(.system(size: 24, weight: .bold))

            // AI Polishing section
            SettingsSection(title: "AI Polishing", icon: "wand.and.stars") {
                VStack(spacing: 16) {
                    SettingsRow(title: "Auto-remove fillers", description: "Remove \"um\", \"uh\", and similar filler words.") {
                        Toggle("", isOn: $settings.autoRemoveFillers)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(title: "Repetition detection", description: "Remove repeated words and phrases.") {
                        Toggle("", isOn: $settings.repetitionDetection)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(title: "Grammar correction", description: "Fix grammatical errors automatically.") {
                        Toggle("", isOn: $settings.grammarCorrection)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(title: "Auto-formatting", description: "Format lists, bullets, and paragraphs.") {
                        Toggle("", isOn: $settings.autoFormatting)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(title: "Mid-sentence correction", description: "Detect \"no wait\" or \"I mean\" and keep only your intent.") {
                        Toggle("", isOn: $settings.midSentenceCorrectionEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }
            }

            // Tone section
            SettingsSection(title: "Tone", icon: "text.quote") {
                VStack(spacing: 16) {
                    SettingsRow(title: "Context-aware tone", description: "Automatically adjust tone based on the active app.") {
                        Toggle("", isOn: $settings.contextAwareToneEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(title: "Default tone", description: "Used when context-aware is disabled.") {
                        Picker("", selection: $settings.preferredTone) {
                            Text("Professional").tag("Professional")
                            Text("Casual").tag("Casual")
                            Text("Concise").tag("Concise")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                        .disabled(settings.contextAwareToneEnabled)
                    }
                }
            }

            // Privacy section
            SettingsSection(title: "Privacy", icon: "lock") {
                VStack(spacing: 16) {
                    SettingsRow(title: "Save dictation history", description: "Store your dictations for later review.") {
                        Toggle("", isOn: $settings.saveHistoryEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(title: "Privacy mode", description: "When enabled, dictations are not saved.") {
                        Toggle("", isOn: $settings.privacyMode)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }
            }
        }
    }
}

// MARK: - About Tab

private struct AboutTabView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            Text("About")
                .font(.system(size: 24, weight: .bold))

            // App info
            HStack(spacing: 16) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Voxify")
                        .font(.system(size: 24, weight: .bold))

                    Text("Version 1.0.0")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Text("Free and open-source voice dictation for macOS")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Credits
            SettingsSection(title: "Credits", icon: "heart") {
                VStack(alignment: .leading, spacing: 12) {
                    CreditItem(name: "Whisper", description: "OpenAI's speech recognition")
                    CreditItem(name: "SwiftUI", description: "Apple's UI framework")
                    CreditItem(name: "macOS Accessibility", description: "Text insertion APIs")
                }
            }

            // Links
            SettingsSection(title: "Links", icon: "link") {
                VStack(spacing: 12) {
                    LinkRow(title: "GitHub Repository", url: "https://github.com/voxify/voxify")
                    LinkRow(title: "Report an Issue", url: "https://github.com/voxify/voxify/issues")
                    LinkRow(title: "License (MIT)", url: "https://opensource.org/licenses/MIT")
                }
            }

            Spacer()
        }
    }
}

// MARK: - Helper Views

private struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content

    init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }

            // Content
            VStack(spacing: 0) {
                content()
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct SettingsRow<Control: View>: View {
    let title: String
    let description: String
    let control: () -> Control

    init(title: String, description: String, @ViewBuilder control: @escaping () -> Control) {
        self.title = title
        self.description = description
        self.control = control
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))

                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            control()
        }
    }
}

private struct ShortcutRow: View {
    let title: String
    let description: String
    let shortcut: String

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))

                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Shortcut badge
            HStack(spacing: 4) {
                ForEach(shortcut.components(separatedBy: "+"), id: \.self) { key in
                    Text(key.trimmingCharacters(in: .whitespaces))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(NSColor.separatorColor).opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
    }
}

private struct EditableShortcutRow: View {
    let title: String
    let description: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))

                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Editable shortcut picker styled as badges
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: { selection = option }) {
                        HStack {
                            Text(option)
                            if selection == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    ForEach(selection.components(separatedBy: "+"), id: \.self) { key in
                        Text(key.trimmingCharacters(in: .whitespaces))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
    }
}

private struct CreditItem: View {
    let name: String
    let description: String

    var body: some View {
        HStack(spacing: 8) {
            Text("\u{2022}")
                .foregroundColor(.accentColor)

            Text(name)
                .font(.system(size: 13, weight: .medium))

            Text("-")
                .foregroundColor(.secondary)

            Text(description)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }
}

private struct LinkRow: View {
    let title: String
    let url: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                NSWorkspace.shared.open(url)
            }
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 13))

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .foregroundColor(.accentColor)
    }
}

#Preview {
    DashboardSettingsView()
        .frame(width: 700, height: 600)
}
