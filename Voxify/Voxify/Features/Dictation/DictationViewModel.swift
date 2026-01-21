import Combine
import ContextDetector
import SwiftUI

final class DictationViewModel: ObservableObject {
    @Published private(set) var rawText = ""
    @Published private(set) var polishedText = ""
    @Published private(set) var isActive = false

    private let coordinator: DictationCoordinator

    init(coordinator: DictationCoordinator = DictationCoordinator()) {
        self.coordinator = coordinator
        coordinator.onUpdate = { [weak self] rawText, polishedText, isFinal in
            DispatchQueue.main.async {
                self?.rawText = rawText
                self?.polishedText = polishedText
                if isFinal {
                    self?.isActive = false
                }
            }
        }
    }

    func start() {
        guard !isActive else { return }
        isActive = true
        let bundleId = ActiveAppDetector().currentBundleIdentifier() ?? "unknown"
        coordinator.start(appBundleId: bundleId)
    }

    func stop() {
        guard isActive else { return }
        coordinator.stop()
        isActive = false
    }
}
