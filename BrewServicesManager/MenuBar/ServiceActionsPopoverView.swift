import SwiftUI

/// The "More Actions" popover for a single service.
struct ServiceActionsPopoverView: View {
    @Environment(ServicesStore.self) private var store
    @Environment(ServiceLinksStore.self) private var linksStore
    @Environment(AppSettings.self) private var settings
    @Environment(\.openURL) private var openURL

    let service: BrewServiceListEntry

    let onAction: (ServiceAction) -> Void
    let onInfo: () -> Void
    let onStopWithOptions: () -> Void
    let onManageLinks: () -> Void

    @Binding var isPresented: Bool
    @State private var isDetectingPorts = false

    /// Links can be suggested only for running services, since ports are detected from live processes.
    private var canSuggestLinks: Bool {
        service.status == .started
    }

    var body: some View {
        let serviceLinks = linksStore.links(for: service.name)

        VStack(alignment: .leading, spacing: .zero) {
            ServiceActionsPopoverHeaderView(service: service, isDetectingPorts: isDetectingPorts)

            Divider()

            VStack(alignment: .leading, spacing: .zero) {
                PopoverActionButton("Run (one-shot)", systemImage: "play") {
                    dismissAndRun { onAction(.run) }
                }

                PopoverActionButton("Start at Login", systemImage: "play.fill") {
                    dismissAndRun { onAction(.start) }
                }

                PopoverActionButton("Restart", systemImage: "arrow.clockwise") {
                    dismissAndRun { onAction(.restart) }
                }

                Divider()
                    .padding(.vertical, LayoutConstants.compactPadding)

                PopoverActionButton("Stop", systemImage: "stop.fill") {
                    dismissAndRun { onAction(.stop(keepRegistered: false)) }
                }

                PopoverActionButton("Stop with Options…", systemImage: "stop.circle") {
                    dismissAndRun(onStopWithOptions)
                }

                PopoverActionButton("Kill", systemImage: "xmark.circle", tint: .red) {
                    dismissAndRun { onAction(.kill) }
                }

                Divider()
                    .padding(.vertical, LayoutConstants.compactPadding)

                if !serviceLinks.isEmpty || canSuggestLinks {
                    ForEach(serviceLinks) { link in
                        PopoverActionButton(verbatim: link.displayLabel, systemImage: "link.circle") {
                            dismissAndRun { openURL(link.url) }
                        }
                    }

                    PopoverActionButton("Manage Links…", systemImage: "link.badge.plus") {
                        dismissAndRun(onManageLinks)
                    }

                    Divider()
                        .padding(.vertical, LayoutConstants.compactPadding)
                }

                PopoverActionButton("View Info", systemImage: "info.circle") {
                    dismissAndRun(onInfo)
                }

                if let fileURL = service.fileURL {
                    PopoverActionButton("Open in Finder", systemImage: "folder") {
                        dismissAndRun { AppKitBridge.revealInFinder(fileURL) }
                    }

                    PopoverActionButton("Copy File Path", systemImage: "doc.on.doc") {
                        dismissAndRun { AppKitBridge.copyToClipboard(fileURL.path()) }
                    }
                }
            }
            .padding(.vertical, LayoutConstants.compactPadding)
        }
        .task { await detectPortsIfNeeded() }
    }

    private func dismissAndRun(_ action: () -> Void) {
        isPresented = false
        action()
    }

    /// Fetches service info (including listening ports) for running services, unless already cached.
    private func detectPortsIfNeeded() async {
        guard service.status == .started else { return }

        if let info = store.selectedServiceInfo, info.name == service.name, info.detectedPorts != nil {
            return
        }

        isDetectingPorts = true
        await store.fetchServiceInfoWithPorts(
            service.name,
            domain: settings.selectedDomain,
            sudoServiceUser: settings.validatedSudoServiceUser,
            debugMode: settings.debugMode
        )
        isDetectingPorts = false
    }
}
