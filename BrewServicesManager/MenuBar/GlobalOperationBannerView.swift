import SwiftUI

/// Progress banner for a bulk operation such as "Start All".
struct GlobalOperationBannerView: View {
    let operation: GlobalOperation

    var body: some View {
        HStack {
            if operation.status == .running {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: operation.failed > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundStyle(operation.failed > 0 ? .orange : .green)
                    .accessibilityHidden(true)
            }

            Text(operation.title)
                .foregroundStyle(.secondary)

            Spacer()

            Text("\(operation.completed)/\(operation.total)")
                .foregroundStyle(.secondary)
                .font(.caption)
                .accessibilityLabel("\(operation.completed) of \(operation.total) completed")
        }
        .padding(.horizontal)
        .padding(.top, LayoutConstants.compactPadding)
        .accessibilityElement(children: .combine)
    }
}
