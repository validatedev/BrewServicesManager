//
//  ServiceLinksManagementListView.swift
//  BrewServicesManager
//

import SwiftUI

struct ServiceLinksManagementListView: View {
    @Environment(ServiceLinksStore.self) private var linksStore
    @Environment(\.openURL) private var openURL

    let serviceName: String
    let suggestedPorts: [ServicePort]
    let onDismiss: () -> Void
    let onAddLink: () -> Void
    let onEditLink: (ServiceLink) -> Void

    private var links: [ServiceLink] {
        linksStore.links(for: serviceName)
    }

    var body: some View {
        VStack(spacing: .zero) {
            PanelHeaderView(title: "Service Links", onBack: onDismiss)

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
                    // Suggestions section
                    if !suggestedPorts.isEmpty && links.isEmpty {
                        PanelSectionCardView(
                            title: "Suggestions",
                            subtitle: "Based on detected ports"
                        ) {
                            ForEach(suggestedPorts.prefix(5)) { port in
                                if let suggestedURL = port.suggestedURL {
                                    ServiceLinkSuggestionRow(
                                        url: suggestedURL,
                                        port: port,
                                        onAdd: {
                                            linksStore.addLink(
                                                ServiceLink(url: suggestedURL),
                                                to: serviceName
                                            )
                                        }
                                    )
                                }
                            }
                        }
                    }

                    // Configured links
                    PanelSectionCardView(title: "Configured Links") {
                        if links.isEmpty {
                            Text("No links configured")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(links) { link in
                                ServiceLinkRow(
                                    link: link,
                                    onOpen: {
                                        openURL(link.url)
                                    },
                                    onEdit: {
                                        onEditLink(link)
                                    },
                                    onDelete: {
                                        linksStore.removeLink(link.id, from: serviceName)
                                    }
                                )
                            }
                        }
                    }

                    // Add button
                    Button("Add Custom Link", systemImage: "plus.circle") {
                        onAddLink()
                    }
                    .buttonStyle(.borderless)
                    .padding(.horizontal, LayoutConstants.headerVerticalPadding)
                }
                .padding(.horizontal, LayoutConstants.compactPadding)
                .padding(.vertical, LayoutConstants.headerVerticalPadding)
            }
        }
    }
}
