import Foundation
import PolishingService

/// Maps application bundle identifiers to their appropriate tone profiles
/// This enables context-aware polishing based on the active application
struct AppToneMapper {
    /// Default tone mappings for common applications
    static let defaultMappings: [String: ContextTone] = [
        // Email apps - Professional
        "com.apple.mail": .professional,
        "com.google.Gmail": .professional,
        "com.microsoft.Outlook": .professional,
        "com.superhuman.Superhuman": .professional,
        "com.readdle.smartemail-Mac": .professional,
        "com.readdle.spark": .professional,
        "com.freron.MailMate": .professional,

        // Slack/Teams - Casual
        "com.tinyspeck.slackmacgap": .casual,
        "com.microsoft.teams": .casual,
        "com.microsoft.teams2": .casual,
        "com.hnc.Discord": .casual,
        "ru.keepcoder.Telegram": .casual,
        "com.facebook.archon.developerID": .casual,
        "net.whatsapp.WhatsApp": .casual,
        "com.apple.MobileSMS": .casual,

        // Professional/Documentation - Professional
        "com.apple.dt.Xcode": .professional,
        "com.microsoft.VSCode": .professional,
        "com.jetbrains.intellij": .professional,
        "com.google.Chrome": .professional,
        "com.apple.Safari": .professional,
        "notion.id": .professional,
        "com.notion.Notion": .professional,

        // Notes - Concise
        "com.apple.Notes": .concise,
        "md.obsidian": .concise,
        "com.evernote.Evernote": .concise,
        "com.todoist.mac.Todoist": .concise,

        // Social Media - Casual
        "com.twitter.twitter-mac": .casual,
        "com.atebits.Tweetie2": .casual,
    ]

    private let customMappings: [String: ContextTone]

    init(customMappings: [String: ContextTone] = [:]) {
        self.customMappings = customMappings
    }

    /// Returns the appropriate tone for a given app bundle ID
    /// Custom mappings take precedence over defaults
    func tone(for bundleId: String) -> ContextTone? {
        // Check custom mappings first
        if let tone = customMappings[bundleId] {
            return tone
        }

        // Fall back to default mappings
        return Self.defaultMappings[bundleId]
    }

    /// Returns a user-friendly app name from bundle ID
    static func appName(for bundleId: String) -> String {
        let knownApps: [String: String] = [
            "com.apple.mail": "Apple Mail",
            "com.google.Gmail": "Gmail",
            "com.microsoft.Outlook": "Outlook",
            "com.tinyspeck.slackmacgap": "Slack",
            "com.microsoft.teams": "Microsoft Teams",
            "com.hnc.Discord": "Discord",
            "ru.keepcoder.Telegram": "Telegram",
            "com.apple.Notes": "Notes",
            "com.notion.Notion": "Notion",
            "md.obsidian": "Obsidian",
            "com.apple.Safari": "Safari",
            "com.google.Chrome": "Chrome",
            "com.microsoft.VSCode": "VS Code",
            "com.apple.dt.Xcode": "Xcode",
        ]

        return knownApps[bundleId] ?? bundleId.components(separatedBy: ".").last ?? bundleId
    }
}
