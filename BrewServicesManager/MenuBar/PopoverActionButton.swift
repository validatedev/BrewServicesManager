import SwiftUI

/// A full-width row button used in the service actions popover.
/// Icons use the secondary text color; pass a `tint` only when the color carries meaning.
struct PopoverActionButton: View {
    let title: Text
    let systemImage: String
    let tint: Color
    let action: () -> Void

    /// Creates a row with a localized title.
    init(_ titleKey: LocalizedStringKey, systemImage: String, tint: Color = .secondary, action: @escaping () -> Void) {
        self.title = Text(titleKey)
        self.systemImage = systemImage
        self.tint = tint
        self.action = action
    }

    /// Creates a row with a runtime title, such as a user-defined link label.
    init(verbatim title: String, systemImage: String, tint: Color = .secondary, action: @escaping () -> Void) {
        self.title = Text(title)
        self.systemImage = systemImage
        self.tint = tint
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label {
                title
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, LayoutConstants.compactPadding)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hoverHighlight()
    }
}
