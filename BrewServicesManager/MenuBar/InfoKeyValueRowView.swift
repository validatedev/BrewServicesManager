import SwiftUI

/// A label/value row in the service info panel.
struct InfoKeyValueRowView: View {
    let label: LocalizedStringKey
    let value: Text

    /// Creates a row whose value is formatted or localized by the caller.
    init(label: LocalizedStringKey, value: Text) {
        self.label = label
        self.value = value
    }

    /// Creates a row whose value is a runtime string, such as a path or user name, shown verbatim.
    init(label: LocalizedStringKey, value: String) {
        self.init(label: label, value: Text(value))
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: LayoutConstants.compactSpacing) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: true, vertical: false)

            value
                .font(.subheadline)
                .textSelection(.enabled)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer(minLength: .zero)
        }
    }
}
