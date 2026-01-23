import Combine
import ContextDetector
import SwiftUI

final class DictationViewModel: ObservableObject {
    @Published private(set) var rawText = ""
    @Published private(set) var polishedText = ""
    @Published private(set) var isActive = false
    @Published private(set) var mode: DictationMode = .holdToTalk
    @Published var statusMessage: String?
    @Published var noFocusText: String?

    /// Current audio level (0.0 - 1.0) for waveform visualization
    @Published private(set) var audioLevel: Float = 0.0

    /// Recent audio levels for waveform history (used for animated visualization)
    @Published private(set) var audioLevelHistory: [Float] = Array(repeating: 0, count: 30)

    /// Current active app name
    @Published private(set) var activeAppName: String = ""

    private let coordinator: DictationCoordinator
    private let permissions: PermissionsManager
    private let settingsStore: SettingsStore
    private let usageStore: UsageStore
    private let historyStore: HistoryStore

    init(
        coordinator: DictationCoordinator = DictationCoordinator(),
        permissions: PermissionsManager = PermissionsManager(),
        settingsStore: SettingsStore = SettingsStore(),
        usageStore: UsageStore = UsageStore(),
        historyStore: HistoryStore = HistoryStore()
    ) {
        self.coordinator = coordinator
        self.permissions = permissions
        self.settingsStore = settingsStore
        self.usageStore = usageStore
        self.historyStore = historyStore

        coordinator.onUpdate = { [weak self] rawText, polishedText, isFinal in
            DispatchQueue.main.async {
                self?.rawText = rawText
                self?.polishedText = polishedText
                if isFinal, self?.mode == .holdToTalk {
                    self?.isActive = false
                }
            }
        }

        coordinator.onNoFocus = { [weak self] text in
            DispatchQueue.main.async {
                self?.noFocusText = text
            }
        }

        coordinator.onAudioLevel = { [weak self] level in
            DispatchQueue.main.async {
                self?.updateAudioLevel(level)
            }
        }
    }

    /// Updates audio level and maintains history for waveform
    private func updateAudioLevel(_ level: Float) {
        // Normalize and amplify the level for better visualization
        let normalizedLevel = min(1.0, level * 5.0)
        audioLevel = normalizedLevel

        // Add to history and maintain fixed size
        var history = audioLevelHistory
        history.append(normalizedLevel)
        if history.count > 30 {
            history.removeFirst()
        }
        audioLevelHistory = history
    }

    func start() {
        start(mode: .holdToTalk)
    }

    func start(mode: DictationMode) {
        guard !isActive else { return }
        let settings = settingsStore.load()
        noFocusText = nil
        statusMessage = nil
        if permissions.microphoneStatus() != .authorized {
            permissions.requestMicrophoneAccess { [weak self] granted in
                if granted {
                    self?.start(mode: mode)
                } else {
                    self?.statusMessage = "Microphone access is required."
                }
            }
            return
        }
        if permissions.speechStatus() != .authorized {
            permissions.requestSpeechAccess { [weak self] granted in
                if granted {
                    self?.start(mode: mode)
                } else {
                    self?.statusMessage = "Speech recognition access is required."
                }
            }
            return
        }
        if !permissions.accessibilityEnabled() {
            _ = permissions.requestAccessibilityAccess()
        }

        isActive = true
        self.mode = mode
        let bundleId = ActiveAppDetector().currentBundleIdentifier() ?? "unknown"
        coordinator.start(
            appBundleId: bundleId,
            mode: mode,
            pauseThresholdSeconds: settings.pauseThresholdSeconds,
            silenceThreshold: settings.silenceThreshold
        )
    }

    func stop() {
        guard isActive else { return }
        coordinator.stop()
        isActive = false
    }

    func toggleContinuous() {
        if isActive && mode == .continuous {
            stop()
        } else {
            start(mode: .continuous)
        }
    }

    func clearNoFocus() {
        noFocusText = nil
    }

    func loadUsage() -> UsageStats {
        usageStore.load()
    }
}
