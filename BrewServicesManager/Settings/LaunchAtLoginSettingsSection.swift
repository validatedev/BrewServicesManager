//
//  LaunchAtLoginSettingsSection.swift
//  BrewServicesManager
//

import SwiftUI

/// Settings section for the launch-at-login toggle and any registration error.
struct LaunchAtLoginSettingsSection: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.openURL) private var openURL

    private static let loginItemsSettingsURL = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension")

    var body: some View {
        @Bindable var settings = settings

        Section("Launch") {
            Toggle(isOn: $settings.launchAtLogin) {
                Text("Launch at login")
                Text("Automatically start when you log in")
            }

            if let error = settings.launchAtLoginError {
                VStack(alignment: .leading, spacing: LayoutConstants.compactSpacing) {
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)

                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button("Open System Settings", systemImage: "gearshape", action: openLoginItemsSettings)
                }
            }
        }
    }

    private func openLoginItemsSettings() {
        if let url = Self.loginItemsSettingsURL {
            openURL(url)
        }
    }
}
