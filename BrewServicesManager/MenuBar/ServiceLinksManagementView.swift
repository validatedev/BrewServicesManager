//
//  ServiceLinksManagementView.swift
//  BrewServicesManager
//

import SwiftUI

struct ServiceLinksManagementView: View {
    @Environment(ServiceLinksStore.self) private var linksStore

    let serviceName: String
    let suggestedPorts: [ServicePort]
    let onDismiss: () -> Void

    @State private var route: ServiceLinksManagementRoute = .list

    var body: some View {
        ZStack {
            // Main list view
            ServiceLinksManagementListView(
                serviceName: serviceName,
                suggestedPorts: suggestedPorts,
                onDismiss: onDismiss,
                onAddLink: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        route = .add
                    }
                },
                onEditLink: { link in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        route = .edit(link)
                    }
                }
            )
            .opacity(route == .list ? 1 : 0)

            // Add link form overlay
            if route == .add {
                AddServiceLinkView(
                    serviceName: serviceName,
                    onSave: { url, label in
                        linksStore.addLink(ServiceLink(url: url, label: label), to: serviceName)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            route = .list
                        }
                    },
                    onCancel: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            route = .list
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }

            // Edit link form overlay
            if case .edit(let link) = route {
                EditServiceLinkView(
                    link: link,
                    onSave: { url, label in
                        linksStore.updateLink(link.id, in: serviceName, url: url, label: label)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            route = .list
                        }
                    },
                    onCancel: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            route = .list
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
    }
}
