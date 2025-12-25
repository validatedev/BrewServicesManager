//
//  ServiceMenuItemView.swift
//  BrewServicesManager
//

import SwiftUI

/// A service row with always-visible action buttons and popover menu.
struct ServiceMenuItemView: View {
    @Environment(ServicesStore.self) private var store

    let service: BrewServiceListEntry
    let onAction: (ServiceAction) -> Void
    let onInfo: () -> Void
    let onStopWithOptions: () -> Void
    
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
                    onStopWithOptions: onStopWithOptions
                )
            }
        }
    }

    private var operation: ServiceOperation? {
        store.serviceOperations[service.id]
    }

    private var isOperationRunning: Bool {
        operation?.status == .running
    }
}
