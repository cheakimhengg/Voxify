import Combine
import Foundation

final class MenuBarController: ObservableObject {
    @Published private(set) var isDictating = false
    let viewModel: DictationViewModel

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: DictationViewModel = DictationViewModel()) {
        self.viewModel = viewModel

        viewModel.$isActive
            .receive(on: DispatchQueue.main)
            .assign(to: &$isDictating)
    }

    func toggleDictation() {
        if isDictating {
            viewModel.stop()
        } else {
            viewModel.start()
        }
    }
}
