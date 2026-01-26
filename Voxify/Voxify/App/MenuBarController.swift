import AppKit
import Combine
import Foundation
import TextInserter

final class MenuBarController: ObservableObject {
    @Published private(set) var isDictating = false
    let viewModel: DictationViewModel

    private var cancellables = Set<AnyCancellable>()
    private let hotkeyMonitor: HotkeyMonitor
    private let settingsStore = SettingsStore()
    private let ttsService = TTSService()
    private lazy var recordingPopup: RecordingPopupWindow = RecordingPopupWindow()

    init(viewModel: DictationViewModel = DictationViewModel()) {
        self.viewModel = viewModel
        self.hotkeyMonitor = HotkeyMonitor(settingsStore: settingsStore)

        viewModel.$isActive
            .receive(on: DispatchQueue.main)
            .assign(to: &$isDictating)

        // Update popup when text changes
        viewModel.$polishedText
            .combineLatest(viewModel.$isActive, viewModel.$mode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text, isActive, mode in
                guard let self else { return }
                if isActive {
                    let modeStr = mode == .continuous ? "Free Hand" : "Hold"
                    self.recordingPopup.update(isRecording: true, text: text, mode: modeStr)
                }
            }
            .store(in: &cancellables)

        setupHotkeys()
    }

    /// Reload hotkey settings (call when settings change)
    func reloadHotkeys() {
        hotkeyMonitor.loadSettings()
    }

    private func setupHotkeys() {
        // Hold-to-talk: start recording on press
        hotkeyMonitor.onHoldStart = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                if !self.viewModel.isActive || self.viewModel.mode != .continuous {
                    self.viewModel.start(mode: .holdToTalk)
                    self.recordingPopup.update(isRecording: true, text: "", mode: "Hold")
                    self.recordingPopup.showAtCenter()
                }
            }
        }

        // Hold-to-talk: stop recording on release
        hotkeyMonitor.onHoldEnd = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.viewModel.isActive && self.viewModel.mode == .holdToTalk {
                    self.viewModel.stop()
                    // Delay popup dismiss to let text insertion complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.recordingPopup.dismiss()
                    }
                }
            }
        }

        // Hands-free: toggle continuous mode
        hotkeyMonitor.onToggleContinuous = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.viewModel.isActive && self.viewModel.mode == .continuous {
                    // Stop continuous mode
                    self.viewModel.stop()
                    self.recordingPopup.dismiss()
                } else {
                    // Start continuous mode
                    self.viewModel.start(mode: .continuous)
                    self.recordingPopup.update(isRecording: true, text: "", mode: "Free Hand")
                    self.recordingPopup.showAtCenter()
                }
            }
        }

        // TTS: read selected or last dictated text
        hotkeyMonitor.onToggleTTS = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.speakText()
            }
        }

        hotkeyMonitor.start()
    }

    func toggleDictation() {
        if isDictating {
            viewModel.stop()
            recordingPopup.dismiss()
        } else {
            viewModel.start(mode: .holdToTalk)
            recordingPopup.update(isRecording: true, text: "", mode: "Hold")
            recordingPopup.showAtCenter()
        }
    }

    /// Speak the last dictated text or selected text
    func speakText(_ text: String? = nil) {
        let textToSpeak: String
        if let text = text, !text.isEmpty {
            textToSpeak = text
        } else if !viewModel.polishedText.isEmpty {
            textToSpeak = viewModel.polishedText
        } else {
            // Try to get selected text from active app
            let inserter = TextInserter()
            if let state = inserter.focusedTextState(),
               let selectedText = state.selectedText,
               !selectedText.isEmpty {
                textToSpeak = selectedText
            } else {
                return
            }
        }

        if ttsService.isSpeaking {
            ttsService.stop()
        } else {
            let settings = settingsStore.load()
            ttsService.speak(textToSpeak, voice: settings.ttsVoice, rate: settings.ttsRate)
        }
    }

    /// Stop any ongoing TTS
    func stopSpeaking() {
        ttsService.stop()
    }
}
