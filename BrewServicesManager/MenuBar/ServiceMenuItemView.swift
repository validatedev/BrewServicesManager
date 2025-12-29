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

    let service: BrewServiceListEntry
    let onAction: (ServiceAction) -> Void
    let onInfo: () -> Void
    let onStopWithOptions: () -> Void
    let onManageLinks: () -> Void

    @State private var showingPopover = false
    
    var body: some View {
        HStack {
            StatusIndicator(status: service.status)
                .frame(width: LayoutConstants.menuRowIconWidth)
            
            Text(service.displayName)
                .lineLimit(1)

            Spacer()

            if let operation {
                switch operation.status {
                case .idle, .succeeded:
                    EmptyView()
                case .running:
                    ProgressView()
                        .controlSize(.mini)
                case .failed:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }

            // Service links
            if !serviceLinks.isEmpty {
                ForEach(serviceLinks.prefix(2)) { link in
                    Button {
                        AppKitBridge.openURL(link.url)
                    } label: {
                        Image(systemName: "link.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help(link.displayLabel)
                    .disabled(isOperationRunning)
                }

                if serviceLinks.count > 2 {
                    Text("+\(serviceLinks.count - 2)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            // Primary action button
            ServicePrimaryActionButtonView(service: service, onAction: onAction)
                .disabled(isOperationRunning)
            
            // More options button with popover
            Button("More", systemImage: "ellipsis.circle") {
                showingPopover.toggle()
            }
            .labelStyle(.iconOnly)
            .font(.body)
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .disabled(isOperationRunning)
            .popover(isPresented: $showingPopover, arrowEdge: .trailing) {
                ServiceActionsPopoverView(
                    service: service,
                    isPresented: $showingPopover,
                    onAction: onAction,
                    onInfo: onInfo,
                    onStopWithOptions: onStopWithOptions,
                    onManageLinks: onManageLinks
                )
                .task {
                    // Fetch ports when popover appears if not already fetched for this service
                    if store.selectedServiceInfo?.name != service.name ||
                       store.selectedServiceInfo?.detectedPorts == nil {
                        await store.fetchServiceInfoWithPorts(
                            service.name,
                            domain: settings.selectedDomain,
                            sudoServiceUser: settings.validatedSudoServiceUser,
                            debugMode: settings.debugMode
                        )
                    }
                }
            }
        }
    }

    private var operation: ServiceOperation? {
        store.serviceOperations[service.id]
    }

    private var isOperationRunning: Bool {
        operation?.status == .running
    }

    private var serviceLinks: [ServiceLink] {
        linksStore.links(for: service.name)
    }
}
