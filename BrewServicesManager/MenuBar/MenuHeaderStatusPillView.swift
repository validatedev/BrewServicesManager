import SwiftUI

struct MenuHeaderStatusPillView: View {
    @Environment(ServicesStore.self) private var store

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
}
