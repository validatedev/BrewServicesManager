//
//  ServiceMenuItemView.swift
//  BrewServicesManager
//

import SwiftUI

/// A service row with always-visible action buttons and popover menu.
struct ServiceMenuItemView: View {
    @Environment(ServicesStore.self) private var store
    @Environment(ServiceLinksStore.self) private var linksStore
    @Environment(AppSettings.self) private var settings
    @Environment(\.openURL) private var openURL

    let service: BrewServiceListEntry
    let onInfo: (BrewServiceListEntry) -> Void
    let onStopWithOptions: (BrewServiceListEntry) -> Void
    let onManageLinks: (BrewServiceListEntry) -> Void

    @State private var showingPopover = false

    /// Number of link buttons shown inline before collapsing into a "+N" count.
    private static let inlineLinkLimit = 2

    private var operation: ServiceOperation? {
        store.serviceOperations[service.id]
    }

    private var isOperationRunning: Bool {
        operation?.status == .running
    }

    var body: some View {
        let serviceLinks = linksStore.links(for: service.name)

        HStack {
            StatusIndicator(status: service.status)
                .frame(width: LayoutConstants.menuRowIconWidth)

            Text(service.displayName)
                .lineLimit(1)

            Spacer()

            if let operation {
                ServiceOperationStatusIcon(status: operation.status)
            }

            ForEach(serviceLinks.prefix(Self.inlineLinkLimit)) { link in
                Button("Open \(link.displayLabel)", systemImage: "link.circle") {
                    openURL(link.url)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help(link.displayLabel)
                .disabled(isOperationRunning)
            }

            if serviceLinks.count > Self.inlineLinkLimit {
                Text("+\(serviceLinks.count - Self.inlineLinkLimit)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .accessibilityLabel("\(serviceLinks.count - Self.inlineLinkLimit) more links")
            }

            ServicePrimaryActionButtonView(service: service, onAction: perform)
                .disabled(isOperationRunning)

            Button("More Actions", systemImage: "ellipsis.circle", action: togglePopover)
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
                .disabled(isOperationRunning)
                .popover(isPresented: $showingPopover, arrowEdge: .trailing) {
                    ServiceActionsPopoverView(
                        service: service,
                        onAction: perform,
                        onInfo: { onInfo(service) },
                        onStopWithOptions: { onStopWithOptions(service) },
                        onManageLinks: { onManageLinks(service) },
                        isPresented: $showingPopover
                    )
                }
        }
    }

    private func togglePopover() {
        showingPopover.toggle()
    }

    private func perform(_ action: ServiceAction) {
        Task {
            await store.performAction(
                action,
                on: service,
                domain: settings.selectedDomain,
                sudoServiceUser: settings.validatedSudoServiceUser,
                debugMode: settings.debugMode
            )
        }
    }
}
