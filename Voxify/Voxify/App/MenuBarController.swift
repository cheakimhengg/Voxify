import Combine
import Foundation
import AppKit

final class MenuBarController: ObservableObject {
    @Published private(set) var isDictating = false
    let viewModel: DictationViewModel

    private var cancellables = Set<AnyCancellable>()
    private let hotkeyMonitor = HotkeyMonitor()
    private let settingsStore = SettingsStore()
    private lazy var recordingPopup: RecordingPopupWindow = RecordingPopupWindow()

    init(viewModel: DictationViewModel = DictationViewModel()) {
        self.viewModel = viewModel

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

    private func setupHotkeys() {
        // Ctrl hold - start recording
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

        // Ctrl release - stop recording and insert
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

        // Ctrl+Shift - toggle continuous (free hand) mode
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
}
