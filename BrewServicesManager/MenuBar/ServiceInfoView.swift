//
//  ServiceInfoView.swift
//  BrewServicesManager
//

import SwiftUI

/// Displays detailed information about a service.
struct ServiceInfoView: View {
    let serviceName: String
    let onDismiss: () -> Void

    @Environment(ServicesStore.self) private var store
    @Environment(AppSettings.self) private var settings

    private var info: BrewServiceInfoEntry? {
        guard let selected = store.selectedServiceInfo, selected.name == serviceName else {
            return nil
        }
        return selected
    }

    var body: some View {
        VStack(spacing: .zero) {
            PanelHeaderView(title: serviceName, onBack: onDismiss)

            Divider()

            if let info {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
                        if let infoServiceName = info.serviceName, infoServiceName != info.name {
                            HStack(alignment: .firstTextBaseline, spacing: LayoutConstants.compactSpacing) {
                                Text("Service")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: true, vertical: false)

                                Text(infoServiceName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .textSelection(.enabled)

                                Spacer(minLength: .zero)
                            }
                            .padding(.horizontal, LayoutConstants.headerVerticalPadding)
                            .padding(.vertical, LayoutConstants.compactPadding)
                        }

                        ServiceInfoStatusSectionView(info: info)

                        if let ports = info.detectedPorts, !ports.isEmpty {
                            ServiceInfoPortsSectionView(ports: ports)
                        }

                        ServiceInfoFilesSectionView(info: info)

                        if info.command != nil || info.workingDir != nil || info.rootDir != nil {
                            ServiceInfoExecutionSectionView(info: info)
                        }

                        if info.interval != nil || info.cron != nil || info.schedulable == true {
                            ServiceInfoScheduleSectionView(info: info)
                        }
                    }
                    .padding(.horizontal, LayoutConstants.compactPadding)
                    .padding(.vertical, LayoutConstants.headerVerticalPadding)
                }
            } else {
                VStack {
                    ProgressView()
                    Text("Loading…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await store.fetchServiceInfoWithPorts(
                serviceName,
                domain: settings.selectedDomain,
                sudoServiceUser: settings.validatedSudoServiceUser,
                debugMode: settings.debugMode
            )
        }
    }
}

#Preview {
    ServiceInfoView(serviceName: "postgresql@16", onDismiss: { })
        .environment(ServicesStore())
        .environment(AppSettings())
        .frame(width: LayoutConstants.serviceInfoMenuWidth)
}
