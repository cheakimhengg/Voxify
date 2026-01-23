import SwiftUI

/// Navigation items for the dashboard sidebar
enum NavigationItem: String, CaseIterable, Identifiable {
    case home
    case history
    case dictionary
    case settings
    case information

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .history: return "History"
        case .dictionary: return "Dictionary"
        case .settings: return "Settings"
        case .information: return "Information"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .history: return "clock"
        case .dictionary: return "character.book.closed"
        case .settings: return "gearshape"
        case .information: return "info.circle"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .history: return "clock.fill"
        case .dictionary: return "character.book.closed.fill"
        case .settings: return "gearshape.fill"
        case .information: return "info.circle.fill"
        }
    }
}
