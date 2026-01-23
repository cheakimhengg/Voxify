import Foundation

public struct LocalPolisher {
    public init() {}

    public func polish(_ text: String, options: PolishingOptions) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        var result = trimmed

        // Apply mid-sentence correction first (before other processing)
        if options.midSentenceCorrection {
            result = applyMidSentenceCorrection(result)
        }

        if options.removeFillers {
            result = removeFillers(from: result)
        }

        if options.removeRepetitions {
            result = removeImmediateRepetitions(from: result)
        }

        // Apply auto-formatting for lists
        if options.autoFormatLists {
            result = autoFormatLists(result)
        }

        // Apply context-aware tone adjustments
        if let tone = options.contextTone {
            result = applyToneAdjustments(result, tone: tone)
        }

        if options.sentenceCase {
            result = sentenceCase(result)
        }

        return result
    }

    // MARK: - Mid-Sentence Correction Detection

    /// Detects when user changes their mind mid-sentence and keeps only the final intent
    /// E.g., "I want to go to the store, no wait, the mall" -> "I want to go to the mall"
    private func applyMidSentenceCorrection(_ text: String) -> String {
        var result = text

        // Correction phrases that indicate the user is changing their mind
        let correctionPatterns: [(pattern: String, replacement: String)] = [
            // "no wait" patterns - keep what comes after
            ("(?i)(.+?)\\s*,?\\s*no wait\\s*,?\\s*(.+)", "$2"),
            ("(?i)(.+?)\\s*,?\\s*wait no\\s*,?\\s*(.+)", "$2"),

            // "I mean" patterns - keep what comes after
            ("(?i)(.+?)\\s*,?\\s*I mean\\s*,?\\s*(.+)", "$2"),
            ("(?i)(.+?)\\s*,?\\s*what I meant was\\s*,?\\s*(.+)", "$2"),
            ("(?i)(.+?)\\s*,?\\s*what I mean is\\s*,?\\s*(.+)", "$2"),

            // "actually" when used as correction - keep what comes after
            ("(?i)(.+?)\\s*,?\\s*actually\\s+(?:it's|it is|that's|that is|make that)\\s*,?\\s*(.+)", "$2"),
            ("(?i)(.+?)\\s*,?\\s*no actually\\s*,?\\s*(.+)", "$2"),

            // "let me rephrase" patterns
            ("(?i)(.+?)\\s*,?\\s*let me rephrase\\s*,?\\s*(.+)", "$2"),
            ("(?i)(.+?)\\s*,?\\s*let me start over\\s*,?\\s*(.+)", "$2"),
            ("(?i)(.+?)\\s*,?\\s*scratch that\\s*,?\\s*(.+)", "$2"),

            // "or rather" patterns
            ("(?i)(.+?)\\s*,?\\s*or rather\\s*,?\\s*(.+)", "$2"),
            ("(?i)(.+?)\\s*,?\\s*or should I say\\s*,?\\s*(.+)", "$2"),

            // "correction" patterns
            ("(?i)(.+?)\\s*,?\\s*correction\\s*,?\\s*(.+)", "$2"),
            ("(?i)(.+?)\\s*,?\\s*I meant to say\\s*,?\\s*(.+)", "$2"),

            // "never mind" with replacement
            ("(?i)(.+?)\\s*,?\\s*never mind\\s*,?\\s*(.+)", "$2"),
            ("(?i)(.+?)\\s*,?\\s*nevermind\\s*,?\\s*(.+)", "$2"),

            // "make that" patterns - common for number/word corrections
            // E.g., "I need five make that six apples" -> "I need six apples"
            ("(?i)(.+?)\\s+\\w+\\s*,?\\s*make that\\s*,?\\s*(\\w+.*)", "$1 $2"),
        ]

        // Apply regex-based corrections
        for (pattern, replacement) in correctionPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
            }
        }

        // Clean up extra whitespace
        result = result.replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }

    // MARK: - Auto-Formatting for Lists

    /// Detects list-related speech and formats as bullets or numbered lists
    private func autoFormatLists(_ text: String) -> String {
        var result = text

        // Bullet point triggers
        let bulletPatterns: [(pattern: String, replacement: String)] = [
            ("(?i)\\bbullet point\\s*,?\\s*", "• "),
            ("(?i)\\bbullet\\s*,?\\s*", "• "),
            ("(?i)\\bnext bullet\\s*,?\\s*", "\n• "),
            ("(?i)\\bnew bullet\\s*,?\\s*", "\n• "),
            ("(?i)\\bdash\\s*,?\\s*", "- "),
            ("(?i)\\bnext item\\s*,?\\s*", "\n• "),
        ]

        // Numbered list triggers
        let numberedPatterns: [(pattern: String, replacement: String)] = [
            ("(?i)\\bnumber one\\s*,?\\s*", "1. "),
            ("(?i)\\bnumber two\\s*,?\\s*", "2. "),
            ("(?i)\\bnumber three\\s*,?\\s*", "3. "),
            ("(?i)\\bnumber four\\s*,?\\s*", "4. "),
            ("(?i)\\bnumber five\\s*,?\\s*", "5. "),
            ("(?i)\\bnumber six\\s*,?\\s*", "6. "),
            ("(?i)\\bnumber seven\\s*,?\\s*", "7. "),
            ("(?i)\\bnumber eight\\s*,?\\s*", "8. "),
            ("(?i)\\bnumber nine\\s*,?\\s*", "9. "),
            ("(?i)\\bnumber ten\\s*,?\\s*", "10. "),
            ("(?i)\\bfirst\\s*,?\\s*", "1. "),
            ("(?i)\\bsecond\\s*,?\\s*", "2. "),
            ("(?i)\\bthird\\s*,?\\s*", "3. "),
            ("(?i)\\bfourth\\s*,?\\s*", "4. "),
            ("(?i)\\bfifth\\s*,?\\s*", "5. "),
            ("(?i)\\bsixth\\s*,?\\s*", "6. "),
            ("(?i)\\bseventh\\s*,?\\s*", "7. "),
            ("(?i)\\beighth\\s*,?\\s*", "8. "),
            ("(?i)\\bninth\\s*,?\\s*", "9. "),
            ("(?i)\\btenth\\s*,?\\s*", "10. "),
        ]

        // Formatting triggers
        let formatPatterns: [(pattern: String, replacement: String)] = [
            ("(?i)\\bnew line\\s*,?\\s*", "\n"),
            ("(?i)\\bnewline\\s*,?\\s*", "\n"),
            ("(?i)\\bnew paragraph\\s*,?\\s*", "\n\n"),
            ("(?i)\\bparagraph break\\s*,?\\s*", "\n\n"),
        ]

        // Apply all formatting patterns
        for (pattern, replacement) in bulletPatterns + numberedPatterns + formatPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
            }
        }

        return result
    }

    // MARK: - Context-Aware Tone Adjustments

    /// Applies tone-specific adjustments based on the context
    private func applyToneAdjustments(_ text: String, tone: ContextTone) -> String {
        var result = text

        switch tone {
        case .professional:
            // Convert casual phrases to professional equivalents
            let professionalReplacements: [(String, String)] = [
                ("(?i)\\bhey\\b", "Hello"),
                ("(?i)\\bhi\\b", "Hello"),
                ("(?i)\\bthanks\\b", "Thank you"),
                ("(?i)\\bthx\\b", "Thank you"),
                ("(?i)\\basap\\b", "as soon as possible"),
                ("(?i)\\bfyi\\b", "for your information"),
                ("(?i)\\bbtw\\b", "by the way"),
                ("(?i)\\bwanna\\b", "want to"),
                ("(?i)\\bgonna\\b", "going to"),
                ("(?i)\\bgotta\\b", "have to"),
                ("(?i)\\bkinda\\b", "kind of"),
                ("(?i)\\bsorta\\b", "sort of"),
                ("(?i)\\bdunno\\b", "don't know"),
                ("(?i)\\bcuz\\b", "because"),
                ("(?i)\\bcause\\b", "because"),
                ("(?i)\\byeah\\b", "yes"),
                ("(?i)\\byep\\b", "yes"),
                ("(?i)\\bnope\\b", "no"),
                ("(?i)\\bok\\b", "okay"),
                ("(?i)\\bu\\b", "you"),
                ("(?i)\\br\\b", "are"),
                ("(?i)\\bur\\b", "your"),
            ]

            for (pattern, replacement) in professionalReplacements {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(result.startIndex..., in: result)
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
                }
            }

        case .casual:
            // Keep text casual, maybe simplify formal phrases
            let casualReplacements: [(String, String)] = [
                ("(?i)\\bHello\\b", "Hey"),
                ("(?i)\\bThank you very much\\b", "Thanks a lot"),
                ("(?i)\\bI would like to\\b", "I'd like to"),
                ("(?i)\\bI am\\b", "I'm"),
                ("(?i)\\bdo not\\b", "don't"),
                ("(?i)\\bcan not\\b", "can't"),
                ("(?i)\\bwill not\\b", "won't"),
                ("(?i)\\bshould not\\b", "shouldn't"),
                ("(?i)\\bwould not\\b", "wouldn't"),
                ("(?i)\\bcould not\\b", "couldn't"),
            ]

            for (pattern, replacement) in casualReplacements {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(result.startIndex..., in: result)
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
                }
            }

        case .concise:
            // Remove verbose phrases, make text more direct
            let concisePatterns: [(String, String)] = [
                ("(?i)\\bI would like to\\s*", "I'll "),
                ("(?i)\\bI am going to\\s*", "I'll "),
                ("(?i)\\bI think that\\s*", ""),
                ("(?i)\\bI believe that\\s*", ""),
                ("(?i)\\bIn my opinion,?\\s*", ""),
                ("(?i)\\bAs I mentioned before,?\\s*", ""),
                ("(?i)\\bAs you know,?\\s*", ""),
                ("(?i)\\bBasically,?\\s*", ""),
                ("(?i)\\bEssentially,?\\s*", ""),
                ("(?i)\\bIn order to\\s*", "To "),
                ("(?i)\\bDue to the fact that\\s*", "Because "),
                ("(?i)\\bAt this point in time\\s*", "Now "),
                ("(?i)\\bAt the present time\\s*", "Now "),
                ("(?i)\\bIn the event that\\s*", "If "),
                ("(?i)\\bWith regard to\\s*", "About "),
                ("(?i)\\bIn regards to\\s*", "About "),
                ("(?i)\\bA large number of\\s*", "Many "),
                ("(?i)\\bThe majority of\\s*", "Most "),
                ("(?i)\\bIn spite of the fact that\\s*", "Although "),
            ]

            for (pattern, replacement) in concisePatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(result.startIndex..., in: result)
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
                }
            }
        }

        // Clean up double spaces
        result = result.replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }

    // MARK: - Original Methods

    private func removeFillers(from text: String) -> String {
        let fillers = ["um", "uh", "like", "you know", "so", "actually", "basically", "literally", "right", "I guess", "sort of", "kind of", "well", "anyway", "anyhow"]
        var result = text
        for filler in fillers {
            let pattern = "(?i)(^|\\s)\(NSRegularExpression.escapedPattern(for: filler))(\\s|,|$)"
            result = result.replacingOccurrences(of: pattern, with: " ", options: .regularExpression)
        }
        return result.replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func removeImmediateRepetitions(from text: String) -> String {
        let words = text.split(separator: " ")
        var result: [Substring] = []
        var previous: Substring?
        for word in words {
            if word.lowercased() == previous?.lowercased() {
                continue
            }
            result.append(word)
            previous = word
        }
        return result.joined(separator: " ")
    }

    private func sentenceCase(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "" }
        return String(first).uppercased() + trimmed.dropFirst()
    }
}
