import AppKit
import SwiftUI

struct VoxifyHomeView: View {
    @StateObject private var viewModel = DictationViewModel()
    @State private var usage = UsageStore().load()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Voxify")
                    .font(.largeTitle)
                Spacer()
                Button("Settings") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
            }

            DictationOverlayView(viewModel: viewModel)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Today")
                    .font(.headline)
                Text("Words dictated: \(todaysWords())")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .frame(minWidth: 520, minHeight: 520)
        .onAppear {
            usage = UsageStore().load()
        }
    }

    private func todaysWords() -> Int {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: Date())
        return usage.dailyWords[key, default: 0]
    }
}
