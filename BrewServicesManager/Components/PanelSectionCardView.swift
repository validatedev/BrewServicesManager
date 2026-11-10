import SwiftUI

/// A titled card used to group related rows in the service info and links panels.
struct PanelSectionCardView<Content: View>: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.compactSpacing) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            content
        }
        .padding(.horizontal, LayoutConstants.headerVerticalPadding)
        .padding(.vertical, LayoutConstants.compactPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sectionContainer()
    }
}

#Preview {
    PanelSectionCardView(title: "Status", subtitle: "Current launchd state") {
        InfoKeyValueRowView(label: "State", value: "Running")
        InfoKeyValueRowView(label: "PID", value: "4242")
    }
    .padding()
    .frame(width: LayoutConstants.serviceInfoMenuWidth)
}
