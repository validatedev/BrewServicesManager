import SwiftUI

// MARK: - Popover Content

struct ServiceActionsPopoverView: View {
    @Environment(ServicesStore.self) private var store
    @Environment(ServiceLinksStore.self) private var linksStore

    let service: BrewServiceListEntry

    let onAction: (ServiceAction) -> Void
    let onInfo: () -> Void
    let onStopWithOptions: () -> Void
    let onManageLinks: () -> Void

    @Binding var isPresented: Bool

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

    private var servicePortsForDisplay: [ServicePort]? {
        // Get ports from the selected service info if it matches this service
        guard let selectedInfo = store.selectedServiceInfo,
              selectedInfo.name == service.name else {
            return nil
        }
        return selectedInfo.detectedPorts
    }

    private var serviceLinks: [ServiceLink] {
        linksStore.links(for: service.name)
    }

    private var canSuggestLinks: Bool {
        // Show if service is running - we can detect ports
        service.status == .started
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            // Service info header
            VStack(alignment: .leading, spacing: LayoutConstants.compactSpacing) {
                Text(service.displayName)
                    .font(.callout)
                    .lineLimit(1)

                HStack(spacing: LayoutConstants.tightSpacing) {
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
                    HStack(spacing: LayoutConstants.tightSpacing) {
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

                // Port summary
                if let ports = servicePortsForDisplay, !ports.isEmpty {
                    HStack(spacing: LayoutConstants.tightSpacing) {
                        Image(systemName: "network")
                            .foregroundStyle(.secondary)
                            .frame(width: LayoutConstants.menuRowIconWidth)

                        Text(portsDescription(ports))
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption2)
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

                // Links section
                if !serviceLinks.isEmpty || canSuggestLinks {
                    ForEach(serviceLinks) { link in
                        popoverButton(
                            link.displayLabel,
                            icon: "link.circle",
                            color: .blue
                        ) {
                            AppKitBridge.openURL(link.url)
                        }
                    }

                    popoverButton(
                        "Manage Links…",
                        icon: "link.badge.plus",
                        color: .primary
                    ) {
                        onManageLinks()
                    }

                    Divider()
                        .padding(.vertical, LayoutConstants.compactPadding)
                }

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

    private func portsDescription(_ ports: [ServicePort]) -> String {
        let portStrings = ports.prefix(3).map { $0.port.formatted(.number.grouping(.never)) }
        let joined = portStrings.joined(separator: ", ")
        return ports.count > 3 ? "\(joined) +\(ports.count - 3)" : joined
    }
}
