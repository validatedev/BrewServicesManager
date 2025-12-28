//
//  MenuBarRootView.swift
//  BrewServicesManager
//
//

import SwiftUI

/// The main content view for the menu bar extra.
struct MenuBarRootView: View {
    @Environment(ServicesStore.self) private var store
    @Environment(AppSettings.self) private var settings

    @State private var pendingGlobalAction: GlobalActionType?
    @State private var serviceToStop: BrewServiceListEntry?
    @State private var showingSettings = false
    @State private var showingServiceInfo: BrewServiceInfoEntry?
    @State private var managingLinksFor: (service: String, ports: [ServicePort])?
    
    var body: some View {
        let menuContentWidth: CGFloat = if serviceToStop != nil {
            LayoutConstants.menuWidth
        } else if showingSettings {
            LayoutConstants.settingsMenuWidth
        } else if showingServiceInfo != nil {
            LayoutConstants.serviceInfoMenuWidth
        } else if managingLinksFor != nil {
            LayoutConstants.serviceInfoMenuWidth
        } else {
            LayoutConstants.mainMenuWidth
        }

        ZStack {
            // Main content
            MainMenuContentView(
                onSettings: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingSettings = true
                    }
                },
                onServiceInfo: { service in
                    Task {
                        await store.fetchServiceInfoWithPorts(
                            service.name,
                            domain: settings.selectedDomain,
                            sudoServiceUser: settings.validatedSudoServiceUser,
                            debugMode: settings.debugMode
                        )
                        if let info = store.selectedServiceInfo {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingServiceInfo = info
                            }
                        }
                    }
                },
                onStopWithOptions: { service in
                    serviceToStop = service
                },
                onManageLinks: { service in
                    Task {
                        var ports: [ServicePort] = []

                        if let info = store.selectedServiceInfo, info.name == service.name {
                            ports = info.detectedPorts ?? []
                        } else {
                            await store.fetchServiceInfoWithPorts(
                                service.name,
                                domain: settings.selectedDomain,
                                sudoServiceUser: settings.validatedSudoServiceUser,
                                debugMode: settings.debugMode
                            )
                            ports = store.selectedServiceInfo?.detectedPorts ?? []
                        }

                        withAnimation(.easeInOut(duration: 0.2)) {
                            managingLinksFor = (service.name, ports)
                        }
                    }
                },
                onGlobalAction: { action in
                    pendingGlobalAction = action
                }
            )
            .opacity(showingSettings || showingServiceInfo != nil || managingLinksFor != nil ? 0 : 1)
            
            // Settings overlay
            if showingSettings {
                SettingsView {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingSettings = false
                    }
                }
                .transition(.move(edge: .trailing))
            }
            
            // Service Info overlay
            if let info = showingServiceInfo {
                ServiceInfoView(info: info) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingServiceInfo = nil
                    }
                }
                .transition(.move(edge: .trailing))
            }

            // Service Links Management overlay
            if let managingLinks = managingLinksFor {
                ServiceLinksManagementView(
                    serviceName: managingLinks.service,
                    suggestedPorts: managingLinks.ports,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            managingLinksFor = nil
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .frame(width: menuContentWidth)
        .task(id: "\(settings.selectedDomain.rawValue)|\(settings.autoRefreshInterval)|\(settings.validatedSudoServiceUser ?? "")|\(settings.debugMode)") {
            await store.runAutoRefresh(
                domain: settings.selectedDomain,
                sudoServiceUser: settings.validatedSudoServiceUser,
                intervalSeconds: settings.autoRefreshInterval,
                debugMode: settings.debugMode
            )
        }
        .overlay {
            if let service = serviceToStop {
                Button {
                    serviceToStop = nil
                } label: {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss")
                
                StopOptionsView(
                    serviceName: service.displayName,
                    onStop: { keepRegistered, waitBehavior in
                        serviceToStop = nil
                        Task {
                            await store.performAction(
                                .stop(keepRegistered: keepRegistered, waitBehavior: waitBehavior),
                                on: service,
                                domain: settings.selectedDomain,
                                sudoServiceUser: settings.validatedSudoServiceUser,
                                debugMode: settings.debugMode
                            )
                        }
                    },
                    onCancel: {
                        serviceToStop = nil
                    }
                )
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: LayoutConstants.panelCornerRadius))
                .shadow(radius: LayoutConstants.panelShadowRadius)
            }

            if let action = pendingGlobalAction {
                Button {
                    pendingGlobalAction = nil
                } label: {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss")

                GlobalActionConfirmView(
                    action: action,
                    onConfirm: {
                        pendingGlobalAction = nil
                        Task {
                            await executeGlobalAction(action)
                        }
                    },
                    onCancel: {
                        pendingGlobalAction = nil
                    }
                )
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: LayoutConstants.panelCornerRadius))
                .shadow(radius: LayoutConstants.panelShadowRadius)
            }
        }
    }

    private func executeGlobalAction(_ action: GlobalActionType) async {
        let domain = settings.selectedDomain
        let user = settings.validatedSudoServiceUser
        let debugMode = settings.debugMode

        switch action {
        case .startAll:
            await store.performActionOnAll(.start, domain: domain, sudoServiceUser: user, debugMode: debugMode)
        case .stopAll:
            await store.performActionOnAll(.stop(keepRegistered: false), domain: domain, sudoServiceUser: user, debugMode: debugMode)
        case .restartAll:
            await store.performActionOnAll(.restart, domain: domain, sudoServiceUser: user, debugMode: debugMode)
        case .cleanup:
            await store.cleanup(domain: domain, sudoServiceUser: user, debugMode: debugMode)
        }

        pendingGlobalAction = nil
    }
}

#Preview {
    MenuBarRootView()
        .environment(ServicesStore())
        .environment(AppSettings())
}
