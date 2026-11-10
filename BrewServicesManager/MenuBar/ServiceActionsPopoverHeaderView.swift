import SwiftUI

/// Header of the service actions popover: name, status, last operation, and detected ports.
struct ServiceActionsPopoverHeaderView: View {
    @Environment(ServicesStore.self) private var store

    let service: BrewServiceListEntry
    let isDetectingPorts: Bool

    /// Number of ports listed before collapsing the rest into "+N".
    private static let visiblePortLimit = 3

    private var operation: ServiceOperation? {
        store.serviceOperations[service.id]
    }

    /// Ports from the cached service info, when it belongs to this service.
    private var detectedPorts: [ServicePort]? {
        guard let selectedInfo = store.selectedServiceInfo, selectedInfo.name == service.name else {
            return nil
        }
        return selectedInfo.detectedPorts
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.compactSpacing) {
            Text(service.displayName)
                .font(.callout)
                .lineLimit(1)

            HStack(spacing: LayoutConstants.tightSpacing) {
                StatusIndicator(status: service.status)
                    .frame(width: LayoutConstants.menuRowIconWidth)

                Text(service.status.displayName)
                    .foregroundStyle(.secondary)

                if let user = service.user {
                    Text(verbatim: "·")
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)

                    Text(user)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.caption2)
            .accessibilityElement(children: .combine)

            if let operation {
                ServiceOperationSummaryView(serviceID: service.id, operation: operation)
            }

            // Reserve the row for running services so the popover doesn't jump when ports arrive.
            if service.status == .started {
                Label {
                    if let ports = detectedPorts, !ports.isEmpty {
                        Text(portsDescription(ports))
                            .foregroundStyle(.secondary)
                    } else if isDetectingPorts {
                        Text("Detecting…")
                            .foregroundStyle(.tertiary)
                    } else {
                        Text("No ports detected")
                            .foregroundStyle(.tertiary)
                    }
                } icon: {
                    Image(systemName: "network")
                        .foregroundStyle(.secondary)
                        .frame(width: LayoutConstants.menuRowIconWidth)
                }
                .font(.caption2)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, LayoutConstants.compactPadding)
    }

    private func portsDescription(_ ports: [ServicePort]) -> String {
        let shown = ports
            .prefix(Self.visiblePortLimit)
            .map { $0.port.formatted(.number.grouping(.never)) }
            .formatted(.list(type: .and, width: .narrow))
        let hiddenCount = ports.count - Self.visiblePortLimit
        return hiddenCount > 0 ? "\(shown) +\(hiddenCount)" : shown
    }
}
