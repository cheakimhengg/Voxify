import Foundation

final class VoiceCommandExecutor {
    func apply(_ command: VoiceCommand, to selectedText: String) -> String {
        switch command.action {
        case .undo, .redo, .rewriteTone:
            return selectedText
        case .newLine:
            return selectedText + "\n"
        case .newParagraph:
            return selectedText + "\n\n"
        case .deleteLastSentence:
            return deleteLastSentence(in: selectedText)
        case .formatBullets:
            return formatBullets(from: selectedText)
        case .formatNumbered:
            return formatNumbered(from: selectedText)
        case .insertEmoji:
            return selectedText + " 😊"
        }
    }

    private func deleteLastSentence(in text: String) -> String {
        let separators = CharacterSet(charactersIn: ".!?")
        guard let range = text.rangeOfCharacter(from: separators, options: .backwards) else {
            return text
        }
        return String(text[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func formatBullets(from text: String) -> String {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        return lines.map { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.isEmpty ? "" : "- \(trimmed)"
        }.joined(separator: "\n")
    }

    private func formatNumbered(from text: String) -> String {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var index = 1
        return lines.map { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                return ""
            }
            defer { index += 1 }
            return "\(index). \(trimmed)"
        }.joined(separator: "\n")
    }
}
