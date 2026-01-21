import SwiftUI

struct NoFocusPopupView: View {
    let text: String
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("No focused field detected")
                .font(.headline)
            Text(text)
                .font(.body)
            HStack {
                Spacer()
                Button("Copy", action: onCopy)
            }
        }
        .padding(16)
        .frame(minWidth: 320)
    }
}
