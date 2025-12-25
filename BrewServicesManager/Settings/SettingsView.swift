//
//  SettingsView.swift
//  BrewServicesManager
//

import SwiftUI

/// Settings view for configuring app preferences.
struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    let onDismiss: () -> Void
    
    var body: some View {
        @Bindable var settings = settings
        
        VStack(spacing: .zero) {
            PanelHeaderView(title: "Settings", onBack: onDismiss)
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
                    PanelSectionCardView(title: "Service Domain") {
                        Picker("Domain", selection: $settings.selectedDomain) {
                            ForEach(ServiceDomain.allCases, id: \.self) { domain in
                                Text(domain.label).tag(domain)
                            }
                        }
                        .pickerStyle(.menu)
                        .controlSize(.small)

                        Text(settings.selectedDomain.description)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    PanelSectionCardView(title: "System Services") {
                        TextField("Run as user", text: $settings.sudoServiceUser)
                            .textFieldStyle(.roundedBorder)

                        Text("Leave empty for root (--sudo-service-user)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    PanelSectionCardView(title: "Auto-refresh") {
                        Picker("Interval", selection: $settings.autoRefreshInterval) {
                            Text("Disabled").tag(0)
                            Text("30 seconds").tag(30)
                            Text("1 minute").tag(60)
                            Text("5 minutes").tag(300)
                        }
                        .pickerStyle(.menu)
                        .controlSize(.small)
                    }

                    PanelSectionCardView(title: "Debug") {
                        Toggle("Debug mode", isOn: $settings.debugMode)

                        Text("Show detailed Homebrew output")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, LayoutConstants.compactPadding)
                .padding(.vertical, LayoutConstants.headerVerticalPadding)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    SettingsView { }
        .environment(AppSettings())
        .frame(width: LayoutConstants.settingsMenuWidth)
}
