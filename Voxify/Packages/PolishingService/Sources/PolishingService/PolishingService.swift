import Foundation

public protocol PolishingServicing {
    func polish(_ text: String) -> String
    func polish(_ text: String, preserving terms: [String]) -> String
    func polish(_ text: String, preserving terms: [String], options: PolishingOptions) -> String
    func polish(_ text: String, completion: @escaping (String) -> Void)
}

public struct PolishingOptions: Codable, Equatable {
    public let removeFillers: Bool
    public let removeRepetitions: Bool
    public let sentenceCase: Bool
    public let midSentenceCorrection: Bool
    public let autoFormatLists: Bool
    public let contextTone: ContextTone?

    public static let `default` = PolishingOptions(
        removeFillers: true,
        removeRepetitions: true,
        sentenceCase: true,
        midSentenceCorrection: true,
        autoFormatLists: true,
        contextTone: nil
    )

    public init(
        removeFillers: Bool,
        removeRepetitions: Bool,
        sentenceCase: Bool,
        midSentenceCorrection: Bool = true,
        autoFormatLists: Bool = true,
        contextTone: ContextTone? = nil
    ) {
        self.removeFillers = removeFillers
        self.removeRepetitions = removeRepetitions
        self.sentenceCase = sentenceCase
        self.midSentenceCorrection = midSentenceCorrection
        self.autoFormatLists = autoFormatLists
        self.contextTone = contextTone
    }
}

public enum ContextTone: String, Codable, CaseIterable {
    case professional
    case casual
    case concise

    public var description: String {
        switch self {
        case .professional: return "Professional"
        case .casual: return "Casual"
        case .concise: return "Concise"
        }
    }
}

public final class PolishingService: PolishingServicing {
    private let localPolisher: LocalPolisher

    public init(localPolisher: LocalPolisher = LocalPolisher()) {
        self.localPolisher = localPolisher
    }

    public func polish(_ text: String) -> String {
        localPolisher.polish(text, options: .default)
    }

    public func polish(_ text: String, preserving terms: [String]) -> String {
        let polished = localPolisher.polish(text, options: .default)
        return preserve(terms: terms, in: polished)
    }

    public func polish(_ text: String, preserving terms: [String], options: PolishingOptions) -> String {
        let polished = localPolisher.polish(text, options: options)
        return preserve(terms: terms, in: polished)
    }

    public func polish(_ text: String, completion: @escaping (String) -> Void) {
        completion(localPolisher.polish(text, options: .default))
    }

    private func preserve(terms: [String], in text: String) -> String {
        var result = text
        for term in terms where !term.isEmpty {
            if let range = result.range(of: term, options: .caseInsensitive) {
                result.replaceSubrange(range, with: term)
            }
        }
        return result
    }
}
