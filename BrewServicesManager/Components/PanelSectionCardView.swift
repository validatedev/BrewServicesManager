import SwiftUI

struct PanelSectionCardView<Content: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?
    @ViewBuilder let content: () -> Content

    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

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

            content()
        }
        .padding(.horizontal, LayoutConstants.headerVerticalPadding)
        .padding(.vertical, LayoutConstants.compactPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sectionContainer()
    }
}
