import SwiftUI

/// The services portion of the main menu: loading, empty, error, or the service list.
struct MainMenuServicesSectionView: View {
    @Environment(ServicesStore.self) private var store

    let onServiceInfo: (BrewServiceListEntry) -> Void
    let onStopWithOptions: (BrewServiceListEntry) -> Void
    let onManageLinks: (BrewServiceListEntry) -> Void

    var body: some View {
        switch store.state {
        case .idle, .loading:
            ProgressView {
                Text("Loading services…")
                    .foregroundStyle(.secondary)
            }
            .controlSize(.small)
            .frame(maxWidth: .infinity)
            .padding()

        case .refreshing(let services), .loaded(let services):
            if services.isEmpty {
                ContentUnavailableView(
                    "No Services",
                    systemImage: "mug",
                    description: Text("No Homebrew services are installed.")
                )
            } else {
                VStack(alignment: .leading, spacing: LayoutConstants.compactSpacing) {
                    MenuSectionLabel(title: "Services")

                    // Pinned banners stay visible above the (possibly scrolling) list.
                    if let operation = store.globalOperation {
                        GlobalOperationBannerView(operation: operation)
                    }

                    if store.nonFatalError != nil {
                        NonFatalErrorBannerView()
                    }

                    // Scroll only when exceeding the max visible count, so short lists size to fit.
                    if services.count > LayoutConstants.maxVisibleServices {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: LayoutConstants.compactSpacing) {
                                ServiceRowsView(
                                    services: services,
                                    onServiceInfo: onServiceInfo,
                                    onStopWithOptions: onStopWithOptions,
                                    onManageLinks: onManageLinks
                                )
                            }
                        }
                        .frame(height: LayoutConstants.servicesListMaxHeight)
                    } else {
                        ServiceRowsView(
                            services: services,
                            onServiceInfo: onServiceInfo,
                            onStopWithOptions: onStopWithOptions,
                            onManageLinks: onManageLinks
                        )
                    }
                }
                .padding(.vertical, LayoutConstants.compactPadding)
            }

        case .error(let error):
            ServiceErrorView(error: error, copyDiagnostics: store.copyDiagnosticsToClipboard)
        }
    }
}
