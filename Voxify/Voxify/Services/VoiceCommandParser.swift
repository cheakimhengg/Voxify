import Foundation

enum VoiceCommandAction: String, CaseIterable {
    case undo
    case redo
    case newLine
    case newParagraph
    case deleteLastSentence
    case rewriteTone
    case formatBullets
    case formatNumbered
    case insertEmoji
}

struct VoiceCommand: Equatable {
    let action: VoiceCommandAction
    let parameters: [String: String]
}

final class VoiceCommandParser {
    func parse(_ text: String) -> VoiceCommand? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.lowercased().hasPrefix("command:") else {
            return nil
        }

        let commandText = trimmed.dropFirst("command:".count).trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = commandText.lowercased()

        switch normalized {
        case "undo":
            return VoiceCommand(action: .undo, parameters: [:])
        case "redo":
            return VoiceCommand(action: .redo, parameters: [:])
        case "new line":
            return VoiceCommand(action: .newLine, parameters: [:])
        case "new paragraph":
            return VoiceCommand(action: .newParagraph, parameters: [:])
        case "delete last sentence":
            return VoiceCommand(action: .deleteLastSentence, parameters: [:])
        case "rewrite tone":
            return VoiceCommand(action: .rewriteTone, parameters: [:])
        case "format bullets":
            return VoiceCommand(action: .formatBullets, parameters: [:])
        case "format numbered":
            return VoiceCommand(action: .formatNumbered, parameters: [:])
        case "insert emoji":
            return VoiceCommand(action: .insertEmoji, parameters: [:])
        default:
            return nil
        }
    }
}
