import SwiftUI

struct GlobalActionConfirmView: View {
    let action: GlobalActionType
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.sectionSpacing) {
            Label(action.title, systemImage: action.systemImage)
                .font(.headline)

            Text(action.message)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()

                Button("Cancel", role: .cancel, action: onCancel)
                .keyboardShortcut(.cancelAction)

                Button(action.confirmButtonTitle, role: action == .cleanup ? .destructive : nil, action: onConfirm)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: LayoutConstants.menuWidth)
    }
}

#Preview {
    GlobalActionConfirmView(
        action: .restartAll,
        onConfirm: {},
        onCancel: {}
    )
}
