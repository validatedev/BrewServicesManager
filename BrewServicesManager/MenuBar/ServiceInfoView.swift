//
//  ServiceInfoView.swift
//  BrewServicesManager
//

import SwiftUI

/// Displays detailed information about a service.
struct ServiceInfoView: View {
    let info: BrewServiceInfoEntry
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: .zero) {
            PanelHeaderView(title: info.name, onBack: onDismiss)
            
            Divider()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
                    if let serviceName = info.serviceName, serviceName != info.name {
                        HStack(alignment: .firstTextBaseline, spacing: LayoutConstants.compactSpacing) {
                            Text("Service")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: true, vertical: false)

                            Text(serviceName)
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
        }
    }
}

#Preview {
    ServiceInfoView(
        info: BrewServiceInfoEntry(
            name: "postgresql@16",
            serviceName: "homebrew.mxcl.postgresql@16",
            status: .started,
            running: true,
            loaded: true,
            schedulable: false,
            pid: 1234,
            exitCode: nil,
            user: "validate",
            file: "/opt/homebrew/Cellar/postgresql@16/16.1/homebrew.mxcl.postgresql@16.plist",
            registered: true,
            loadedFile: nil,
            command: "/opt/homebrew/opt/postgresql@16/bin/postgres -D /opt/homebrew/var/postgresql@16",
            workingDir: "/opt/homebrew/var",
            rootDir: nil,
            logPath: "/opt/homebrew/var/log/postgresql@16.log",
            errorLogPath: nil,
            interval: nil,
            cron: nil
        ),
        onDismiss: { }
    )
    .frame(width: LayoutConstants.serviceInfoMenuWidth)
}
