//
//  ServiceInfoStatusSectionView.swift
//  BrewServicesManager
//

import SwiftUI

struct ServiceInfoStatusSectionView: View {
    let info: BrewServiceInfoEntry

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
}
