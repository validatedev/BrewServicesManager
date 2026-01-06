import SwiftUI

struct MenuRowButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let isEnabled: Bool
    let showDisclosure: Bool
    let action: () -> Void

    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        isEnabled: Bool = true,
        showDisclosure: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isEnabled = isEnabled
        self.showDisclosure = showDisclosure
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: LayoutConstants.menuRowIconWidth)

                Text(title)
                
                Spacer()
                
                if showDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, LayoutConstants.compactPadding)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hoverHighlight(isEnabled: isEnabled)
        .disabled(!isEnabled)
    }
}
