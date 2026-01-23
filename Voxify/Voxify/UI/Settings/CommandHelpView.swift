import SwiftUI

struct CommandHelpView: View {
    private let commands: [(String, String)] = [
        ("command: undo", "Undo the last change"),
        ("command: redo", "Redo the last change"),
        ("command: new line", "Insert a line break"),
        ("command: new paragraph", "Insert a paragraph break"),
        ("command: delete last sentence", "Remove the most recent sentence"),
        ("command: format bullets", "Format selection as bullets"),
        ("command: format numbered", "Format selection as numbered list"),
        ("command: insert emoji", "Insert a friendly emoji")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Voice Commands")
                .font(.headline)

            ForEach(commands, id: \.0) { command, description in
                HStack(alignment: .top, spacing: 12) {
                    Text(command)
                        .font(.body)
                        .frame(width: 200, alignment: .leading)
                    Text(description)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .frame(minWidth: 420)
    }
}
