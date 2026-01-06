//
//  SettingsView.swift
//  BrewServicesManager
//

import SwiftUI
import AppKit

/// Settings view for configuring app preferences.
struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(AppUpdater.self) private var appUpdater
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

                    PanelSectionCardView(title: "Launch") {
                        Toggle("Launch at login", isOn: $settings.launchAtLogin)

                        Text("Automatically start when you log in")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        // Show error if present
                        if let error = settings.launchAtLoginError {
                            VStack(alignment: .leading, spacing: LayoutConstants.compactSpacing) {
                                Label("Error", systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red)

                                Text(error.localizedDescription)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)

                                if let suggestion = error.recoverySuggestion {
                                    Text(suggestion)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }

                                Button("Open System Settings", systemImage: "gearshape") {
                                    if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
                                        AppKitBridge.openURL(url)
                                    }
                                }
                                .font(.caption)
                            }
                            .padding(.top, LayoutConstants.compactPadding)
                        }
                    }

                    PanelSectionCardView(title: "Updates") {
                        Button("Check for Updates…") {
                            appUpdater.checkForUpdates()
                        }
                        .disabled(!appUpdater.canCheckForUpdates)
                        .controlSize(.small)

                        Toggle("Automatically check for updates", isOn: $settings.automaticallyCheckForUpdates)
                            .onChange(of: settings.automaticallyCheckForUpdates) { _, newValue in
                                appUpdater.automaticallyChecksForUpdates = newValue
                            }

                        Text(settings.automaticallyCheckForUpdates
                             ? "New versions are delivered automatically"
                             : "Check manually using the button above")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    PanelSectionCardView(title: "About") {
                        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

                        LabeledContent("Version", value: "\(version) (\(build))")
                            .font(.callout)
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
        .environment(AppUpdater())
        .frame(width: LayoutConstants.settingsMenuWidth)
}
