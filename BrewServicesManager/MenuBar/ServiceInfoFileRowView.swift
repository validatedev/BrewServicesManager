import SwiftUI

struct ServiceInfoFileRowView: View {
    let label: String
    let path: String
    let url: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
            HStack(spacing: LayoutConstants.compactSpacing) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: .zero)

                if let url {
                    Button("Open", systemImage: "folder") {
                        AppKitBridge.revealInFinder(url)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .controlSize(.mini)
                }

                Button("Copy", systemImage: "doc.on.doc") {
                    AppKitBridge.copyToClipboard(path)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .controlSize(.mini)
            }

            Text(path)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
        }
    }
}
