import SwiftUI

struct GeneralSettingsView: View {
    @State private var settings = SettingsStore().load()

    var body: some View {
        Form {
            Section("Activation") {
                Toggle("Enable Hold-to-Talk Hotkey", isOn: $settings.holdToTalkEnabled)
                Toggle("Enable Continuous Mode Hotkey", isOn: $settings.continuousModeEnabled)
                Toggle("Beep on Start/Stop", isOn: $settings.beepEnabled)
                HStack {
                    Text("Pause Threshold (sec)")
                    Spacer()
                    TextField("3.5", value: $settings.pauseThresholdSeconds, format: .number)
                        .frame(width: 80)
                }
            }

            Section {
                Toggle("Auto-Remove Fillers", isOn: $settings.autoRemoveFillers)
                Toggle("Repetition Detection", isOn: $settings.repetitionDetection)
                Toggle("Grammar Correction", isOn: $settings.grammarCorrection)
                Toggle("Auto-Formatting (lists, bullets)", isOn: $settings.autoFormatting)
                Toggle("Mid-Sentence Correction", isOn: $settings.midSentenceCorrectionEnabled)
                    .help("Detects when you change your mind mid-sentence and keeps only the final intent")
            } header: {
                Text("AI Polishing")
            } footer: {
                Text("Mid-sentence correction detects phrases like \"no wait\" or \"I mean\" and keeps only your intended message.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Toggle("Context-Aware Tone", isOn: $settings.contextAwareToneEnabled)
                    .help("Automatically adjusts tone based on the active application")

                Picker("Default Tone", selection: $settings.preferredTone) {
                    Text("Professional").tag("Professional")
                    Text("Casual").tag("Casual")
                    Text("Concise").tag("Concise")
                }
                .disabled(settings.contextAwareToneEnabled)
            } header: {
                Text("Tone Settings")
            } footer: {
                if settings.contextAwareToneEnabled {
                    Text("Tone is automatically adjusted: Professional for email apps, Casual for chat apps, Concise for notes.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section("Visual Feedback") {
                Toggle("Show Audio Waveform", isOn: $settings.showAudioWaveform)
                    .help("Display animated waveform during recording")
            }

            Section("Language") {
                TextField("Language Hint (optional)", text: Binding(
                    get: { settings.languageHint ?? "" },
                    set: { settings.languageHint = $0.isEmpty ? nil : $0 }
                ))
            }

            Section {
                Toggle("Save Dictation History", isOn: $settings.saveHistoryEnabled)
                    .help("Store your dictations for later review")

                Toggle("Privacy Mode (No Retention)", isOn: $settings.privacyMode)
                    .help("When enabled, dictations are not saved to history")
            } header: {
                Text("Privacy & History")
            } footer: {
                if settings.privacyMode {
                    Text("Privacy mode is enabled. Dictations will not be saved to history.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            Section("Goals") {
                Stepper("Daily Word Goal: \(settings.dailyWordGoal)", value: $settings.dailyWordGoal, in: 0...10000, step: 100)
            }
        }
        .onChange(of: settings) { newValue in
            SettingsStore().save(newValue)
        }
        .padding(12)
    }
}
