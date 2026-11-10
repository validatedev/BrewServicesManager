import SwiftUI

/// Warning banner shown when some operations failed but the service list is still usable.
struct NonFatalErrorBannerView: View {
    @Environment(ServicesStore.self) private var store

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Label("Some operations failed", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Spacer()

            Button("Copy Diagnostics", systemImage: "doc.on.doc", action: copyDiagnostics)

            Button("Dismiss", systemImage: "xmark", action: dismiss)
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.top, LayoutConstants.compactPadding)
    }

    private func copyDiagnostics() {
        store.copyDiagnosticsToClipboard()
    }

    private func dismiss() {
        store.nonFatalError = nil
    }
}
