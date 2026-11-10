//
//  MainMenuContentView.swift
//  BrewServicesManager
//

import SwiftUI

/// The main content of the menu bar (services list, global actions, quit).
struct MainMenuContentView: View {
    @Environment(ServicesStore.self) private var store
    @Environment(AppSettings.self) private var settings

    let onSettings: () -> Void
    let onServiceInfo: (BrewServiceListEntry) -> Void
    let onStopWithOptions: (BrewServiceListEntry) -> Void
    let onManageLinks: (BrewServiceListEntry) -> Void
    let onGlobalAction: (GlobalActionType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            MenuBarHeaderView()

            Divider()

            MainMenuServicesSectionView(
                onServiceInfo: onServiceInfo,
                onStopWithOptions: onStopWithOptions,
                onManageLinks: onManageLinks
            )

            Divider()

            MenuSectionLabel(title: "Actions")
            GlobalActionsView(onAction: onGlobalAction)

            Divider()
                .padding(.top, LayoutConstants.compactPadding)

            MenuSectionLabel(title: "App")

            MenuRowButton("Refresh", systemImage: "arrow.clockwise", isEnabled: !store.isRefreshing, action: refresh)

            MenuRowButton("Settings…", systemImage: "gear", showDisclosure: true, action: onSettings)

            Divider()
                .padding(.vertical, LayoutConstants.compactPadding)

            MenuRowButton("Quit", systemImage: "power", action: AppKitBridge.quit)
        }
        // Leave breathing room below the last row instead of letting it touch the window edge (issue #6).
        .padding(.bottom, LayoutConstants.headerVerticalPadding)
    }

    private func refresh() {
        Task {
            await store.refresh(
                domain: settings.selectedDomain,
                sudoServiceUser: settings.validatedSudoServiceUser,
                debugMode: settings.debugMode,
                force: true
            )
        }
    }
}
