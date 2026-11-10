import SwiftUI

/// Compact indicator for a per-service operation: a spinner while running, a warning when it failed.
struct ServiceOperationStatusIcon: View {
    let status: ServiceOperationStatus

    var body: some View {
        switch status {
        case .idle, .succeeded:
            EmptyView()
        case .running:
            ProgressView()
                .controlSize(.mini)
                .accessibilityLabel("Working")
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .accessibilityLabel("Last operation failed")
        }
    }
}
