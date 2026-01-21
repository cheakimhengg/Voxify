import SwiftUI

struct DictationOverlayView: View {
    @ObservedObject var viewModel: DictationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.isActive ? "Dictating" : "Idle")
                .font(.headline)
            Text(viewModel.rawText)
                .font(.body)
            Text(viewModel.polishedText)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(minWidth: 280)
    }
}
