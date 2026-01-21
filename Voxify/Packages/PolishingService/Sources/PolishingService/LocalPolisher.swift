import Foundation

public struct LocalPolisher {
    public init() {}

    public func polish(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else {
            return ""
        }
        let capitalized = String(first).uppercased() + trimmed.dropFirst()
        return capitalized
    }
}
