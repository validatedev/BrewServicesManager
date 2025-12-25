import SwiftUI

// MARK: - Popover Content

struct ServiceActionsPopoverView: View {
    @Environment(ServicesStore.self) private var store

    let service: BrewServiceListEntry
    @Binding var isPresented: Bool

    let onAction: (ServiceAction) -> Void
    let onInfo: () -> Void
    let onStopWithOptions: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            // Service info header
            VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                Text(service.displayName)
                    .font(.callout)
                    .lineLimit(1)

                HStack {
                    StatusIndicator(status: service.status)
                        .frame(width: LayoutConstants.menuRowIconWidth)

                    Text(popoverStatusTitle)
                        .foregroundStyle(.secondary)

                    if let user = service.user {
                        Text("·")
                            .foregroundStyle(.tertiary)

                        Text(user)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption2)

                if let operation {
                    HStack {
                        switch operation.status {
                        case .idle, .succeeded:
                            EmptyView()
                        case .running:
                            Label("Working…", systemImage: "hourglass")
                                .foregroundStyle(.secondary)
                                .font(.caption2)
                        case .failed:
                            Label("Last operation failed", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.caption2)
                        }

                        Spacer()

                        if operation.status == .failed {
                            Button("Copy Diagnostics", systemImage: "doc.on.doc") {
                                store.copyDiagnosticsToClipboard(for: service.id)
                            }
                            .font(.caption2)
                        }
                    }

                    if let message = operation.error?.localizedDescription {
                        Text(message)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, LayoutConstants.compactPadding)

            Divider()

            // Action buttons
            VStack(alignment: .leading, spacing: .zero) {
                popoverButton("Run (one-shot)", icon: "play", color: .primary) {
                    onAction(.run)
                }

                popoverButton("Start at Login", icon: "play.fill", color: .green) {
                    onAction(.start)
                }

                popoverButton("Restart", icon: "arrow.clockwise", color: .orange) {
                    onAction(.restart)
                }

                Divider()
                    .padding(.vertical, LayoutConstants.compactPadding)

                popoverButton("Stop", icon: "stop.fill", color: .red) {
                    onAction(.stop(keepRegistered: false))
                }

                popoverButton("Stop with Options…", icon: "stop.circle", color: .red) {
                    onStopWithOptions()
                }

                popoverButton("Kill", icon: "xmark.circle", color: .red) {
                    onAction(.kill)
                }

                Divider()
                    .padding(.vertical, LayoutConstants.compactPadding)

                popoverButton("View Info", icon: "info.circle", color: .primary) {
                    onInfo()
                }

                if let fileURL = service.fileURL {
                    popoverButton("Open in Finder", icon: "folder", color: .primary) {
                        AppKitBridge.revealInFinder(fileURL)
                    }

                    popoverButton("Copy File Path", icon: "doc.on.doc", color: .primary) {
                        AppKitBridge.copyToClipboard(fileURL.path())
                    }
                }
            }
            .padding(.vertical, LayoutConstants.compactPadding)
        }
    }

    private var operation: ServiceOperation? {
        store.serviceOperations[service.id]
    }

    private var popoverStatusTitle: LocalizedStringKey {
        switch service.status {
        case .started:
            "Running"
        case .stopped:
            "Stopped"
        case .scheduled:
            "Scheduled"
        case .none:
            "Unloaded"
        case .error:
            "Error"
        case .unknown:
            "Unknown"
        }
    }

    // MARK: - Popover Button Helper

    private func popoverButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            isPresented = false
            action()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)

                Text(title)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, LayoutConstants.compactPadding)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
