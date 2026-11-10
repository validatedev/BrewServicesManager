//
//  SettingsView.swift
//  BrewServicesManager
//

import SwiftUI

/// Settings view for configuring app preferences.
///
/// Uses a grouped `Form` so rows, labels, and descriptions follow the native
/// System Settings layout. A second `Text` in a control's label renders as its
/// secondary description.
struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    let onDismiss: () -> Void

    var body: some View {
        @Bindable var settings = settings

        VStack(spacing: .zero) {
            PanelHeaderView(title: Text("Settings"), onBack: onDismiss)

            Divider()

            Form {
                Section("Services") {
                    Picker(selection: $settings.selectedDomain) {
                        ForEach(ServiceDomain.allCases, id: \.self) { domain in
                            Text(domain.label).tag(domain)
                        }
                    } label: {
                        Text("Domain")
                        Text(settings.selectedDomain.description)
                    }

                    TextField(text: $settings.sudoServiceUser, prompt: Text("root")) {
                        Text("Run system services as")
                        Text("Leave empty for root (--sudo-service-user)")
                    }

                    Picker("Auto-refresh", selection: $settings.autoRefreshInterval) {
                        Text("Disabled").tag(0)
                        Text("30 seconds").tag(30)
                        Text("1 minute").tag(60)
                        Text("5 minutes").tag(300)
                    }
                }

                LaunchAtLoginSettingsSection()

                UpdatesSettingsSection()

                Section("Advanced") {
                    Toggle(isOn: $settings.debugMode) {
                        Text("Debug mode")
                        Text("Show detailed Homebrew output")
                    }
                }

                AboutSettingsSection()
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    SettingsView { }
        .environment(AppSettings())
        .environment(AppUpdater())
        .frame(width: LayoutConstants.settingsMenuWidth, height: 520)
}
