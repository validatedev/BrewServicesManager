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
    let onGlobalAction: (GlobalActionType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            MenuBarHeaderView()
            
            Divider()
            
            // Services section
            MainMenuServicesSectionView(
                onServiceInfo: onServiceInfo,
                onStopWithOptions: onStopWithOptions
            )
            
            Divider()
            
            // Actions section
            MenuSectionLabel(title: "Actions")
            GlobalActionsView(onAction: onGlobalAction)
            
            Divider()
            
            // App section
            MenuSectionLabel(title: "App")
            
            MenuRowButton("Refresh", systemImage: "arrow.clockwise", isEnabled: !store.isRefreshing) {
                Task {
                    await store.refresh(
                        domain: settings.selectedDomain,
                        sudoServiceUser: settings.validatedSudoServiceUser,
                        debugMode: settings.debugMode,
                        force: true
                    )
                }
            }

            MenuRowButton("Settings…", systemImage: "gear", showDisclosure: true) {
                onSettings()
            }

            Divider()

            MenuRowButton("Quit", systemImage: "power") {
                AppKitBridge.quit()
            }
        }
    }
}
