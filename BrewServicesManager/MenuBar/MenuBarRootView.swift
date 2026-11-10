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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var pendingGlobalAction: GlobalActionType?
    @State private var route: MenuBarRoute = .main
    @State private var serviceToStop: BrewServiceListEntry?

    private var menuContentWidth: CGFloat {
        if serviceToStop != nil {
            return LayoutConstants.menuWidth
        }

        return switch route {
        case .settings:
            LayoutConstants.settingsMenuWidth
        case .serviceInfo, .manageLinks:
            LayoutConstants.serviceInfoMenuWidth
        case .main:
            LayoutConstants.mainMenuWidth
        }
    }

    private var panelTransition: AnyTransition {
        MotionConstants.panelEdgeTransition(reduceMotion: reduceMotion)
    }

    var body: some View {
        ZStack {
            MainMenuContentView(
                onSettings: { navigate(to: .settings) },
                onServiceInfo: { service in navigate(to: .serviceInfo(service.name)) },
                onStopWithOptions: { service in serviceToStop = service },
                onManageLinks: showManageLinks,
                onGlobalAction: { action in pendingGlobalAction = action }
            )
            .opacity(route == .main ? 1 : 0)

            switch route {
            case .main:
                EmptyView()

            case .settings:
                SettingsView(onDismiss: navigateToMain)
                    .transition(panelTransition)

            case .serviceInfo(let serviceName):
                ServiceInfoView(serviceName: serviceName, onDismiss: navigateToMain)
                    .transition(panelTransition)

            case .manageLinks(let serviceName, let ports):
                ServiceLinksManagementView(
                    serviceName: serviceName,
                    suggestedPorts: ports,
                    onDismiss: navigateToMain
                )
                .transition(panelTransition)
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
                MenuModalOverlay(onDismiss: { serviceToStop = nil }) {
                    StopOptionsView(
                        serviceName: service.displayName,
                        onStop: { keepRegistered, waitBehavior in
                            stop(service, keepRegistered: keepRegistered, waitBehavior: waitBehavior)
                        },
                        onCancel: { serviceToStop = nil }
                    )
                }
            }

            if let action = pendingGlobalAction {
                MenuModalOverlay(onDismiss: { pendingGlobalAction = nil }) {
                    GlobalActionConfirmView(
                        action: action,
                        onConfirm: { confirmGlobalAction(action) },
                        onCancel: { pendingGlobalAction = nil }
                    )
                }
            }
        }
    }

    // MARK: - Navigation

    private func navigate(to newRoute: MenuBarRoute) {
        withAnimation(MotionConstants.panelTransition) {
            route = newRoute
        }
    }

    private func navigateToMain() {
        navigate(to: .main)
    }

    /// Loads detected ports (reusing cached info when it matches) before opening the links panel,
    /// so the panel can offer suggestions immediately.
    private func showManageLinks(for service: BrewServiceListEntry) {
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

            navigate(to: .manageLinks(service: service.name, ports: ports))
        }
    }

    // MARK: - Actions

    private func stop(_ service: BrewServiceListEntry, keepRegistered: Bool, waitBehavior: StopWaitBehavior) {
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
    }

    private func confirmGlobalAction(_ action: GlobalActionType) {
        pendingGlobalAction = nil
        Task {
            await executeGlobalAction(action)
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
    }
}

#Preview {
    MenuBarRootView()
        .environment(ServicesStore())
        .environment(AppSettings())
        .environment(ServiceLinksStore())
        .environment(AppUpdater())
}
