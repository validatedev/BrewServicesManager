//
//  BrewServicesManagerApp.swift
//  BrewServicesManager
//

import SwiftUI

@main
struct BrewServicesManagerApp: App {
    @State private var servicesStore = ServicesStore()
    @State private var appSettings = AppSettings()
    @State private var serviceLinksStore = ServiceLinksStore()
    @State private var appUpdater = AppUpdater()

    private var iconName: String {
        if !servicesStore.isBrewAvailable {
            return "mug.fill"  // Error state
        }

        if servicesStore.globalOperation?.status == .running {
            return "gearshape.2"
        }

        if servicesStore.isRefreshing {
            return "mug"  // Loading state
        }

        // Check if any service has an error
        let hasError = servicesStore.nonFatalError != nil || servicesStore.services.contains { $0.status == .error }
        if hasError {
            return "exclamationmark.triangle.fill"
        }

        // Show different icon for system domain
        if appSettings.selectedDomain == .system {
            return "lock.fill"
        }

        // Show badge when update is available and waiting for user attention
        if appUpdater.hasUpdateWaitingForAttention {
            return "mug.badge.plus"
        }

        return "mug.fill"  // Normal state
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarRootView()
                .environment(servicesStore)
                .environment(appSettings)
                .environment(serviceLinksStore)
                .environment(appUpdater)
                .task {
                    // Sync settings with Sparkle on launch
                    appUpdater.automaticallyChecksForUpdates = appSettings.automaticallyCheckForUpdates
                }
        } label: {
            Label("Brew Services Manager", systemImage: iconName)
                .labelStyle(.iconOnly)
        }
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)
    }
}
