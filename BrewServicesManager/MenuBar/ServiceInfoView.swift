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
                VStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
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

// MARK: - Section Views

struct ServiceInfoStatusSectionView: View {
    let info: BrewServiceInfoEntry
    
    var body: some View {
        PanelSectionCardView(title: "Status") {
            InfoKeyValueRowView(label: "State", value: statusTitle)

            if let running = info.running {
                InfoKeyValueRowView(label: "Running", value: running ? "Yes" : "No")
            }

            if let loaded = info.loaded {
                InfoKeyValueRowView(label: "Loaded", value: loaded ? "Yes" : "No")
            }

            if let pid = info.pid {
                InfoKeyValueRowView(label: "PID", value: String(pid))
            }

            if let exitCode = info.exitCode {
                InfoKeyValueRowView(label: "Exit Code", value: String(exitCode))
            }

            if let user = info.user {
                InfoKeyValueRowView(label: "User", value: user)
            }
        }
    }

    private var statusTitle: String {
        switch info.status {
        case .started:
            "Running"
        case .stopped:
            "Stopped"
        case .scheduled:
            "Scheduled"
        case .none:
            "Unloaded"
        case .error:
            "Error"
        case .unknown:
            "Unknown"
        }
    }
}

struct ServiceInfoFilesSectionView: View {
    let info: BrewServiceInfoEntry
    
    var body: some View {
        PanelSectionCardView(title: "Files") {
            if let file = info.file {
                ServiceInfoFileRowView(label: "Service File", path: file, url: info.fileURL)
            }

            if let logPath = info.logPath {
                ServiceInfoFileRowView(label: "Log", path: logPath, url: info.logURL)
            }

            if let errorLogPath = info.errorLogPath {
                ServiceInfoFileRowView(label: "Error Log", path: errorLogPath, url: info.errorLogURL)
            }
        }
    }
}

struct ServiceInfoExecutionSectionView: View {
    let info: BrewServiceInfoEntry
    
    var body: some View {
        PanelSectionCardView(title: "Launch", subtitle: "What launchd runs to start this service") {
            if let command = info.command {
                VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                    Text("Launch Command")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(command)
                        .font(.caption)
                        .textSelection(.enabled)
                }
            }

            if let workingDir = info.workingDir {
                InfoKeyValueRowView(label: "Working Directory", value: workingDir)
            }

            if let rootDir = info.rootDir {
                InfoKeyValueRowView(label: "Root Directory", value: rootDir)
            }
        }
    }
}

struct ServiceInfoScheduleSectionView: View {
    let info: BrewServiceInfoEntry

    var body: some View {
        PanelSectionCardView(title: "Schedule") {
            if let schedulable = info.schedulable {
                InfoKeyValueRowView(label: "Schedulable", value: schedulable ? "Yes" : "No")
            }

            if let interval = info.interval {
                InfoKeyValueRowView(label: "Interval", value: "\(interval) seconds")
            }

            if let cron = info.cron {
                InfoKeyValueRowView(label: "Cron", value: cron)
            }
        }
    }
}

struct ServiceInfoPortsSectionView: View {
    let ports: [ServicePort]

    var body: some View {
        PanelSectionCardView(title: "Listening Ports") {
            ForEach(ports) { port in
                HStack(alignment: .firstTextBaseline, spacing: LayoutConstants.compactSpacing) {
                    Text(port.portProtocol.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: true, vertical: false)

                    Text(port.port, format: .number.grouping(.never))
                        .font(.subheadline)
                        .textSelection(.enabled)

                    Spacer(minLength: .zero)
                }
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
