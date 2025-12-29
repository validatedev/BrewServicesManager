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

    @State private var showingAddLink = false
    @State private var editingLink: ServiceLink?

    private var links: [ServiceLink] {
        linksStore.links(for: serviceName)
    }

    var body: some View {
        ZStack {
            // Main list view
            mainListView
                .opacity(showingAddLink || editingLink != nil ? 0 : 1)

            // Add link form overlay
            if showingAddLink {
                AddServiceLinkView(
                    serviceName: serviceName,
                    onSave: { url, label in
                        linksStore.addLink(ServiceLink(url: url, label: label), to: serviceName)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingAddLink = false
                        }
                    },
                    onCancel: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingAddLink = false
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }

            // Edit link form overlay
            if let link = editingLink {
                EditServiceLinkView(
                    link: link,
                    onSave: { url, label in
                        linksStore.updateLink(link.id, in: serviceName, url: url, label: label)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            editingLink = nil
                        }
                    },
                    onCancel: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            editingLink = nil
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
    }

    private var mainListView: some View {
        VStack(spacing: .zero) {
            PanelHeaderView(title: "Service Links", onBack: onDismiss)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
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
                                        AppKitBridge.openURL(link.url)
                                    },
                                    onEdit: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            editingLink = link
                                        }
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
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingAddLink = true
                        }
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

// MARK: - Sub-Views

struct ServiceLinkSuggestionRow: View {
    let url: URL
    let port: ServicePort
    let onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(url.absoluteString)
                    .font(.caption)
                Text("Port \(port.port, format: .number.grouping(.never))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Add", systemImage: "plus.circle.fill") {
                onAdd()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .foregroundStyle(.green)
        }
    }
}

struct ServiceLinkRow: View {
    let link: ServiceLink
    let onOpen: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(link.displayLabel)
                    .font(.caption)
                Text(link.url.absoluteString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            Button("Open", systemImage: "arrow.up.forward.square") {
                onOpen()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)

            Button("Edit", systemImage: "pencil") {
                onEdit()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)

            Button("Delete", systemImage: "trash") {
                onDelete()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .foregroundStyle(.red)
        }
    }
}

struct AddServiceLinkView: View {
    let serviceName: String
    let onSave: (URL, String?) -> Void
    let onCancel: () -> Void

    @State private var urlString = ""
    @State private var label = ""
    @FocusState private var urlFieldFocused: Bool

    private var isValid: Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased() else {
            return false
        }

        // Block potentially malicious schemes - allow everything else
        let blockedSchemes = ["javascript", "data", "file"]

        return !blockedSchemes.contains(scheme)
    }

    var body: some View {
        VStack(spacing: .zero) {
            PanelHeaderView(title: "Add Link", onBack: onCancel)

            Divider()

            VStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
                Text("Add link for \(serviceName)")
                    .font(.headline)

                VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                    Text("URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("http://localhost:8080", text: $urlString)
                        .textFieldStyle(.roundedBorder)
                        .focused($urlFieldFocused)
                }

                VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                    Text("Label (optional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("My Service", text: $label)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Spacer()

                    Button("Cancel") {
                        onCancel()
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Add") {
                        if let url = URL(string: urlString) {
                            let trimmedLabel = label.trimmingCharacters(in: .whitespaces)
                            onSave(url, trimmedLabel.isEmpty ? nil : trimmedLabel)
                        }
                    }
                    .disabled(!isValid)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, LayoutConstants.compactPadding)
            }
            .padding()

            Spacer()
        }
        .onAppear {
            urlFieldFocused = true
        }
    }
}

struct EditServiceLinkView: View {
    let link: ServiceLink
    let onSave: (URL, String?) -> Void
    let onCancel: () -> Void

    @State private var urlString: String
    @State private var label: String
    @FocusState private var urlFieldFocused: Bool

    init(link: ServiceLink, onSave: @escaping (URL, String?) -> Void, onCancel: @escaping () -> Void) {
        self.link = link
        self.onSave = onSave
        self.onCancel = onCancel
        _urlString = State(initialValue: link.url.absoluteString)
        _label = State(initialValue: link.label ?? "")
    }

    private var isValid: Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased() else {
            return false
        }

        // Block potentially malicious schemes - allow everything else
        let blockedSchemes = ["javascript", "data", "file"]

        return !blockedSchemes.contains(scheme)
    }

    var body: some View {
        VStack(spacing: .zero) {
            PanelHeaderView(title: "Edit Link", onBack: onCancel)

            Divider()

            VStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
                VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                    Text("URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("http://localhost:8080", text: $urlString)
                        .textFieldStyle(.roundedBorder)
                        .focused($urlFieldFocused)
                }

                VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                    Text("Label (optional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("My Service", text: $label)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Spacer()

                    Button("Cancel") {
                        onCancel()
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Save") {
                        if let url = URL(string: urlString) {
                            let trimmedLabel = label.trimmingCharacters(in: .whitespaces)
                            onSave(url, trimmedLabel.isEmpty ? nil : trimmedLabel)
                        }
                    }
                    .disabled(!isValid)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, LayoutConstants.compactPadding)
            }
            .padding()

            Spacer()
        }
        .onAppear {
            urlFieldFocused = true
        }
    }
}
