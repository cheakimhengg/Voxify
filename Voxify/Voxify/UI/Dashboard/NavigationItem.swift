import SwiftUI

/// Navigation items for the dashboard sidebar
enum NavigationItem: String, CaseIterable, Identifiable {
    case home
    case history
    case dictionary
    case information

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .history: return "History"
        case .dictionary: return "Dictionary"
        case .information: return "Information"
        }
    }

    /// Get localized title based on language setting
    func localizedTitle(language: String) -> String {
        let isKhmer = language == "Khmer"
        switch self {
        case .home: return isKhmer ? "ទំព័រដើម" : "Home"
        case .history: return isKhmer ? "ប្រវត្តិ" : "History"
        case .dictionary: return isKhmer ? "វចនានុក្រម" : "Dictionary"
        case .information: return isKhmer ? "ព័ត៌មាន" : "Information"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .history: return "clock"
        case .dictionary: return "character.book.closed"
        case .information: return "info.circle"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .history: return "clock.fill"
        case .dictionary: return "character.book.closed.fill"
        case .information: return "info.circle.fill"
        }
    }
}
