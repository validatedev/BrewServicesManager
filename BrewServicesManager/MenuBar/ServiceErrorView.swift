import SwiftUI

struct ServiceErrorView: View {
    let error: AppError
    let copyDiagnostics: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.compactSpacing) {
            Label("Error", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button("Copy Diagnostics", systemImage: "doc.on.doc") {
                copyDiagnostics()
            }
            .font(.caption)
        }
        .padding()
    }
}
