import SwiftUI

struct MenuHeaderStatusPillView: View {
    @Environment(ServicesStore.self) private var store

    var body: some View {
        Group {
            if status == .refreshing {
                ProgressView()
                    .controlSize(.mini)
                    .tint(.secondary)
                    .padding(.horizontal, LayoutConstants.statusBadgeHorizontalPadding)
                    .padding(.vertical, LayoutConstants.statusBadgeVerticalPadding)
                    .background(status.background, in: .capsule)
                    .accessibilityLabel(status.accessibilityLabel)
            } else {
                Label(status.title, systemImage: status.systemImage)
                    .font(.caption2)
                    .foregroundStyle(status.foregroundStyle)
                    .padding(.horizontal, LayoutConstants.statusBadgeHorizontalPadding)
                    .padding(.vertical, LayoutConstants.statusBadgeVerticalPadding)
                    .background(status.background, in: .capsule)
                    .accessibilityLabel(status.accessibilityLabel)
            }
        }
    }

    private var status: HeaderStatus {
        if !store.isBrewAvailable {
            return .homebrewRequired
        }

        if store.globalOperation?.status == .running {
            return .operating
        }

        if store.isRefreshing {
            return .refreshing
        }

        if store.nonFatalError != nil {
            return .warning
        }

        if case .error = store.state {
            return .error
        }

        return .ready
    }
}

private enum HeaderStatus {
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

    var foregroundStyle: Color {
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

    var background: AnyShapeStyle {
        switch self {
        case .ready:
            AnyShapeStyle(Color.green.opacity(LayoutConstants.headerStatusPillTintOpacity))
        case .operating:
            AnyShapeStyle(.thinMaterial)
        case .refreshing:
            AnyShapeStyle(.thinMaterial)
        case .homebrewRequired:
            AnyShapeStyle(Color.orange.opacity(LayoutConstants.headerStatusPillTintOpacity))
        case .warning:
            AnyShapeStyle(Color.orange.opacity(LayoutConstants.headerStatusPillTintOpacity))
        case .error:
            AnyShapeStyle(Color.red.opacity(LayoutConstants.headerStatusPillTintOpacity))
        }
    }
}
