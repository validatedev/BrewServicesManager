//
//  UpdatesSettingsSection.swift
//  BrewServicesManager
//

import SwiftUI

/// Settings section for Sparkle update preferences.
struct UpdatesSettingsSection: View {
    @Environment(AppSettings.self) private var settings
    @Environment(AppUpdater.self) private var appUpdater

    var body: some View {
        @Bindable var settings = settings

        Section("Updates") {
            Toggle(isOn: $settings.automaticallyCheckForUpdates) {
                Text("Automatically check for updates")
                Text(settings.automaticallyCheckForUpdates
                     ? "New versions are delivered automatically"
                     : "Check manually using the button below")
            }
            .onChange(of: settings.automaticallyCheckForUpdates) { _, newValue in
                appUpdater.automaticallyChecksForUpdates = newValue
            }

            Button("Check for Updates…", action: appUpdater.checkForUpdates)
                .disabled(!appUpdater.canCheckForUpdates)
        }
    }
}
