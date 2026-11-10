import SwiftUI

/// One row per service; shared by the plain and scrolling layouts of the services section.
struct ServiceRowsView: View {
    let services: [BrewServiceListEntry]
    let onServiceInfo: (BrewServiceListEntry) -> Void
    let onStopWithOptions: (BrewServiceListEntry) -> Void
    let onManageLinks: (BrewServiceListEntry) -> Void

    var body: some View {
        ForEach(services) { service in
            ServiceMenuItemView(
                service: service,
                onInfo: onServiceInfo,
                onStopWithOptions: onStopWithOptions,
                onManageLinks: onManageLinks
            )
            .padding(.horizontal)
            .padding(.vertical, LayoutConstants.tightSpacing)
        }
    }
}
