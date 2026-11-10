import SwiftUI

/// Shown in place of the service list when loading services failed.
struct ServiceErrorView: View {
    let error: AppError
    let copyDiagnostics: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Couldn't Load Services", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text(error.localizedDescription)

            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
            }
        } actions: {
            Button("Copy Diagnostics", systemImage: "doc.on.doc", action: copyDiagnostics)
        }
    }
}
