import SwiftUI

enum HeaderStatus {
    case ready
    case operating
    case refreshing
    case homebrewRequired
    case warning
    case error

    var title: LocalizedStringKey {
        switch self {
        case .ready:
            "Ready"
        case .operating:
            "Working…"
        case .refreshing:
            "Syncing…"
        case .homebrewRequired:
            "Brew missing"
        case .warning:
            "Warning"
        case .error:
            "Error"
        }
    }

    var accessibilityLabel: LocalizedStringKey {
        switch self {
        case .ready:
            "Ready"
        case .operating:
            "Working"
        case .refreshing:
            "Refreshing"
        case .homebrewRequired:
            "Homebrew missing"
        case .warning:
            "Warning"
        case .error:
            "Error"
        }
    }

    var systemImage: String {
        switch self {
        case .ready:
            "checkmark.circle.fill"
        case .operating:
            "gearshape.2.fill"
        case .refreshing:
            "arrow.clockwise"
        case .homebrewRequired:
            "exclamationmark.triangle.fill"
        case .warning:
            "exclamationmark.triangle.fill"
        case .error:
            "exclamationmark.circle.fill"
        }
    }

    /// Semantic color for the status icon; the title stays secondary.
    var iconStyle: Color {
        switch self {
        case .ready:
            .green
        case .operating:
            .secondary
        case .refreshing:
            .secondary
        case .homebrewRequired:
            .orange
        case .warning:
            .orange
        case .error:
            .red
        }
    }
}
