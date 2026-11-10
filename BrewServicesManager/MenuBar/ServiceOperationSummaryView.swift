import SwiftUI

/// Describes the latest per-service operation inside the actions popover.
struct ServiceOperationSummaryView: View {
    @Environment(ServicesStore.self) private var store

    let serviceID: String
    let operation: ServiceOperation

    var body: some View {
        HStack(spacing: LayoutConstants.tightSpacing) {
            switch operation.status {
            case .idle, .succeeded:
                EmptyView()
            case .running:
                Label("Working…", systemImage: "hourglass")
                    .foregroundStyle(.secondary)
            case .failed:
                Label("Last operation failed", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }

            Spacer()

            if operation.status == .failed {
                Button("Copy Diagnostics", systemImage: "doc.on.doc", action: copyDiagnostics)
            }
        }
        .font(.caption2)

        if let message = operation.error?.localizedDescription {
            Text(message)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }

    private func copyDiagnostics() {
        store.copyDiagnosticsToClipboard(for: serviceID)
    }
}
