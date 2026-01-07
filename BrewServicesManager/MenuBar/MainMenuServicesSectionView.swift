import SwiftUI

struct MainMenuServicesSectionView: View {
    @Environment(ServicesStore.self) private var store
    @Environment(AppSettings.self) private var settings

    let onServiceInfo: (BrewServiceListEntry) -> Void
    let onStopWithOptions: (BrewServiceListEntry) -> Void
    let onManageLinks: (BrewServiceListEntry) -> Void

    var body: some View {
        Group {
            switch store.state {
            case .idle, .loading:
                HStack {
                    ProgressView()
                        .controlSize(.small)

                    Text("Loading services…")
                        .foregroundStyle(.secondary)
                }
                .padding()

            case .refreshing(let services), .loaded(let services):
                if services.isEmpty {
                    Text("No Homebrew services installed")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: LayoutConstants.compactSpacing) {
                        MenuSectionLabel(title: "Services")

                        // Pinned: Operation status (always visible)
                        if let operation = store.globalOperation {
                            HStack {
                                if operation.status == .running {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: operation.failed > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                        .foregroundStyle(operation.failed > 0 ? .orange : .green)
                                }

                                Text(operation.title)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text("\(operation.completed)/\(operation.total)")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            .padding(.horizontal)
                            .padding(.top, LayoutConstants.compactPadding)
                        }

                        // Pinned: Error banner (always visible)
                        if store.nonFatalError != nil {
                            HStack(alignment: .firstTextBaseline) {
                                Label("Some operations failed", systemImage: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)

                                Spacer()

                                Button("Copy Diagnostics", systemImage: "doc.on.doc") {
                                    store.copyDiagnosticsToClipboard()
                                }

                                Button("Dismiss", systemImage: "xmark") {
                                    store.nonFatalError = nil
                                }
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.top, LayoutConstants.compactPadding)
                        }

                        // Service rows - scrollable only when exceeding max visible count
                        if services.count > LayoutConstants.maxVisibleServices {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: .zero) {
                                    ForEach(services) { service in
                                        serviceRow(for: service)
                                    }
                                }
                            }
                            .frame(height: LayoutConstants.servicesListMaxHeight)
                            .scrollIndicators(.automatic)
                        } else {
                            ForEach(services) { service in
                                serviceRow(for: service)
                            }
                        }
                    }
                    .padding(.vertical, LayoutConstants.compactPadding)
                }

            case .error(let error):
                ServiceErrorView(error: error, copyDiagnostics: store.copyDiagnosticsToClipboard)
            }
        }
    }

    @ViewBuilder
    private func serviceRow(for service: BrewServiceListEntry) -> some View {
        ServiceMenuItemView(
            service: service,
            onAction: { action in
                Task {
                    await store.performAction(
                        action,
                        on: service,
                        domain: settings.selectedDomain,
                        sudoServiceUser: settings.validatedSudoServiceUser,
                        debugMode: settings.debugMode
                    )
                }
            },
            onInfo: {
                onServiceInfo(service)
            },
            onStopWithOptions: {
                onStopWithOptions(service)
            },
            onManageLinks: {
                onManageLinks(service)
            }
        )
        .padding(.horizontal)
    }
}
