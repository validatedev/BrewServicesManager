import SwiftUI

struct MenuHeaderStatusPillView: View {
    @Environment(ServicesStore.self) private var store

    var body: some View {
        let status = store.headerStatus

        Group {
            if status == .refreshing {
                ProgressView()
                    .controlSize(.mini)
                    .tint(.secondary)
            } else {
                Label {
                    Text(status.title)
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: status.systemImage)
                        .foregroundStyle(status.iconStyle)
                }
                .font(.caption2)
            }
        }
        .padding(.horizontal, LayoutConstants.statusBadgeHorizontalPadding)
        .padding(.vertical, LayoutConstants.statusBadgeVerticalPadding)
        .background(.quinary, in: .capsule)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(status.accessibilityLabel)
    }
}
