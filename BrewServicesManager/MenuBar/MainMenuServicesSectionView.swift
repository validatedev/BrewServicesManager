import SwiftUI

struct MainMenuServicesSectionView: View {
    @Environment(ServicesStore.self) private var store
    @Environment(AppSettings.self) private var settings

    let onServiceInfo: (BrewServiceListEntry) -> Void
    let onStopWithOptions: (BrewServiceListEntry) -> Void

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

                        ForEach(services) { service in
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
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, LayoutConstants.compactPadding)
                }

            case .error(let error):
                ServiceErrorView(error: error, copyDiagnostics: store.copyDiagnosticsToClipboard)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
