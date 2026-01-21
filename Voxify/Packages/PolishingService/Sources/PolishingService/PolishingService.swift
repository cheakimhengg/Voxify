import Foundation

public protocol PolishingServicing {
    func polish(_ text: String) -> String
    func polish(_ text: String, preserving terms: [String]) -> String
    func polish(_ text: String, completion: @escaping (String) -> Void)
}

public final class PolishingService: PolishingServicing {
    private let localPolisher: LocalPolisher

    public init(localPolisher: LocalPolisher = LocalPolisher()) {
        self.localPolisher = localPolisher
    }

    public func polish(_ text: String) -> String {
        localPolisher.polish(text)
    }

    public func polish(_ text: String, preserving terms: [String]) -> String {
        let polished = localPolisher.polish(text)
        return preserve(terms: terms, in: polished)
    }

    public func polish(_ text: String, completion: @escaping (String) -> Void) {
        completion(localPolisher.polish(text))
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
