//
//  ServiceLinksManagementView.swift
//  BrewServicesManager
//

import SwiftUI

/// Hosts the links list and the add/edit form for one service.
struct ServiceLinksManagementView: View {
    @Environment(ServiceLinksStore.self) private var linksStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let serviceName: String
    let suggestedPorts: [ServicePort]
    let onDismiss: () -> Void

    @State private var route: ServiceLinksManagementRoute = .list

    var body: some View {
        ZStack {
            ServiceLinksManagementListView(
                serviceName: serviceName,
                suggestedPorts: suggestedPorts,
                onDismiss: onDismiss,
                onAddLink: { navigate(to: .add) },
                onEditLink: { link in navigate(to: .edit(link)) }
            )
            .opacity(route == .list ? 1 : 0)

            switch route {
            case .list:
                EmptyView()

            case .add:
                ServiceLinkFormView(
                    title: Text("Add Link to \(serviceName)"),
                    confirmTitle: "Add",
                    onSave: { url, label in
                        linksStore.addLink(ServiceLink(url: url, label: label), to: serviceName)
                        navigate(to: .list)
                    },
                    onCancel: { navigate(to: .list) }
                )
                .transition(MotionConstants.panelEdgeTransition(reduceMotion: reduceMotion))

            case .edit(let link):
                ServiceLinkFormView(
                    title: Text("Edit Link"),
                    confirmTitle: "Save",
                    link: link,
                    onSave: { url, label in
                        linksStore.updateLink(link.id, in: serviceName, url: url, label: label)
                        navigate(to: .list)
                    },
                    onCancel: { navigate(to: .list) }
                )
                .transition(MotionConstants.panelEdgeTransition(reduceMotion: reduceMotion))
            }
        }
    }

    private func navigate(to newRoute: ServiceLinksManagementRoute) {
        withAnimation(MotionConstants.panelTransition) {
            route = newRoute
        }
    }
}
