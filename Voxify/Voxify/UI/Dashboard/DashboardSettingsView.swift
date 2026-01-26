import SwiftUI

/// Settings tab options
enum SettingsTab: String, CaseIterable, Identifiable {
    case account
    case settings
    case personalization

    var id: String { rawValue }

    var title: String {
        switch self {
        case .account: return "Account"
        case .settings: return "Settings"
        case .personalization: return "Personalization"
        }
    }

    var icon: String {
        switch self {
        case .account: return "person.circle"
        case .settings: return "gearshape"
        case .personalization: return "paintbrush"
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
                .frame(width: 200)
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
                SettingsTabButtonLocalized(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    isKhmer: settings.interfaceLanguage == "Khmer"
                ) {
                    selectedTab = tab
                }
            }

            Spacer()

            // External links
            Divider()
                .padding(.vertical, 8)

            ExternalLinkButton(
                title: settings.interfaceLanguage == "Khmer" ? "មជ្ឈមណ្ឌលជំនួយ" : "Help center",
                icon: "questionmark.circle"
            )
            ExternalLinkButton(
                title: settings.interfaceLanguage == "Khmer" ? "កំណត់ចំណាំកំណែ" : "Release notes",
                icon: "doc.text"
            )
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

private struct SettingsTabButtonLocalized: View {
    let tab: SettingsTab
    let isSelected: Bool
    let isKhmer: Bool
    let action: () -> Void

    private var localizedTitle: String {
        if isKhmer {
            switch tab {
            case .account: return "គណនី"
            case .settings: return "ការកំណត់"
            case .personalization: return "ការកំណត់ផ្ទាល់ខ្លួន"
            }
        }
        return tab.title
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14))
                    .frame(width: 20)

                Text(localizedTitle)
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
    @State private var showResetAlert = false
    private let settingsStore = SettingsStore()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            Text(settings.interfaceLanguage == "Khmer" ? "ការកំណត់" : "Settings")
                .font(.system(size: 24, weight: .bold))

            // Keyboard shortcuts section
            SettingsSection(
                title: settings.interfaceLanguage == "Khmer" ? "ផ្លូវកាត់ក្តារចុច" : "Keyboard shortcuts",
                icon: "keyboard"
            ) {
                VStack(spacing: 16) {
                    HotkeySettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "សង្កត់ដើម្បីនិយាយ" : "Hold to Talk",
                        description: settings.interfaceLanguage == "Khmer" ? "សង្កត់ដើម្បីនិយាយ។ លែងដើម្បីបញ្ចូលអត្ថបទ។" : "Hold down to speak. Release to insert text.",
                        hotkeyConfig: $settings.holdToTalkHotkey
                    )

                    Divider()

                    HotkeySettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "របៀបដោយស្វ័យប្រវត្តិ" : "Hands-free Mode",
                        description: settings.interfaceLanguage == "Khmer" ? "ចុចម្តងដើម្បីចាប់ផ្តើមនិយាយ។ ចុចម្តងទៀតដើម្បីបញ្ឈប់។" : "Press once to start speaking. Press again to stop.",
                        hotkeyConfig: $settings.handsFreeHotkey
                    )

                    Divider()

                    HotkeySettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "អានឮ (TTS)" : "Read Aloud (TTS)",
                        description: settings.interfaceLanguage == "Khmer" ? "អានអត្ថបទចុងក្រោយឬអត្ថបទដែលបានជ្រើសរើស។" : "Read the last dictated or selected text aloud.",
                        hotkeyConfig: $settings.ttsHotkey
                    )
                }
            }

            // Language section
            SettingsSection(
                title: settings.interfaceLanguage == "Khmer" ? "ភាសា" : "Language",
                icon: "globe"
            ) {
                VStack(spacing: 16) {
                    SettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "ភាសាចំណុចប្រទាក់" : "Interface language",
                        description: settings.interfaceLanguage == "Khmer" ? "ជ្រើសរើសភាសាសម្រាប់កម្មវិធី។" : "Choose the language for the app interface."
                    ) {
                        Picker("", selection: $settings.interfaceLanguage) {
                            Text("English").tag("English")
                            Text("ខ្មែរ (Khmer)").tag("Khmer")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                    }

                    Divider()

                    SettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "ការសម្គាល់សម្រាប់សំឡេង" : "Speech recognition hint",
                        description: settings.interfaceLanguage == "Khmer" ? "ភាសាសម្រាប់ការសម្គាល់សំឡេង។" : "Language hint for better accuracy."
                    ) {
                        Picker("", selection: Binding(
                            get: { settings.languageHint ?? "auto" },
                            set: { settings.languageHint = $0 == "auto" ? nil : $0 }
                        )) {
                            Text(settings.interfaceLanguage == "Khmer" ? "ស្វ័យប្រវត្តិ" : "Auto-detect").tag("auto")
                            Text("English").tag("en-US")
                            Text("ខ្មែរ").tag("km-KH")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                    }
                }
            }

            // Audio section
            SettingsSection(
                title: settings.interfaceLanguage == "Khmer" ? "សំឡេង" : "Audio",
                icon: "speaker.wave.2"
            ) {
                VStack(spacing: 16) {
                    SettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "សំឡេងបើក/បិទ" : "Beep on start/stop",
                        description: settings.interfaceLanguage == "Khmer" ? "លេងសំឡេងនៅពេលចាប់ផ្តើម/បញ្ឈប់។" : "Play a sound when dictation starts and stops."
                    ) {
                        Toggle("", isOn: $settings.beepEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "បង្ហាញរលកសំឡេង" : "Show audio waveform",
                        description: settings.interfaceLanguage == "Khmer" ? "បង្ហាញរលកសំឡេងនៅពេលថត។" : "Display animated waveform during recording."
                    ) {
                        Toggle("", isOn: $settings.showAudioWaveform)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "រយៈពេលផ្អាក" : "Pause threshold",
                        description: settings.interfaceLanguage == "Khmer" ? "វិនាទីនៃភាពស្ងាត់មុនពេលបញ្ឈប់។" : "Seconds of silence before auto-stopping."
                    ) {
                        HStack {
                            TextField("", value: $settings.pauseThresholdSeconds, format: .number)
                                .textFieldStyle(.plain)
                                .frame(width: 60)
                                .padding(6)
                                .background(Color(NSColor.controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            Text(settings.interfaceLanguage == "Khmer" ? "វិនាទី" : "sec")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                        }
                    }
                }
            }

            // Text-to-Speech section
            SettingsSection(
                title: settings.interfaceLanguage == "Khmer" ? "អានជាសំឡេង" : "Text-to-Speech",
                icon: "speaker.wave.3"
            ) {
                VStack(spacing: 16) {
                    SettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "បើក TTS" : "Enable TTS",
                        description: settings.interfaceLanguage == "Khmer" ? "អនុញ្ញាតឱ្យអានជាសំឡេង។" : "Allow reading text aloud with keyboard shortcut."
                    ) {
                        Toggle("", isOn: $settings.ttsEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    SettingsRow(
                        title: settings.interfaceLanguage == "Khmer" ? "ល្បឿនអាន" : "Speech rate",
                        description: settings.interfaceLanguage == "Khmer" ? "ល្បឿនក្នុងការអានអត្ថបទ។" : "How fast the text is read."
                    ) {
                        HStack {
                            Slider(value: $settings.ttsRate, in: 0.1...1.0, step: 0.1)
                                .frame(width: 120)

                            Text(String(format: "%.1fx", settings.ttsRate * 2))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 40)
                        }
                    }
                }
            }

            // Reset section
            SettingsSection(
                title: settings.interfaceLanguage == "Khmer" ? "កំណត់ឡើងវិញ" : "Reset",
                icon: "arrow.counterclockwise"
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(settings.interfaceLanguage == "Khmer" ? "កំណត់ការកំណត់ទាំងអស់ឡើងវិញ" : "Reset all settings")
                            .font(.system(size: 13, weight: .medium))
                        Text(settings.interfaceLanguage == "Khmer" ? "ស្តារការកំណត់ទាំងអស់ទៅតម្លៃដើម។" : "Restore all settings to their default values.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(settings.interfaceLanguage == "Khmer" ? "កំណត់ឡើងវិញ" : "Reset") {
                        showResetAlert = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
        .alert(
            settings.interfaceLanguage == "Khmer" ? "កំណត់ការកំណត់ឡើងវិញ?" : "Reset Settings?",
            isPresented: $showResetAlert
        ) {
            Button(settings.interfaceLanguage == "Khmer" ? "បោះបង់" : "Cancel", role: .cancel) {}
            Button(settings.interfaceLanguage == "Khmer" ? "កំណត់ឡើងវិញ" : "Reset", role: .destructive) {
                settingsStore.resetToDefaults()
                settings = settingsStore.load()
            }
        } message: {
            Text(settings.interfaceLanguage == "Khmer" ? "នេះនឹងកំណត់ការកំណត់ទាំងអស់ទៅតម្លៃដើម។" : "This will reset all settings to their default values.")
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

#Preview {
    DashboardSettingsView()
        .frame(width: 700, height: 600)
}
