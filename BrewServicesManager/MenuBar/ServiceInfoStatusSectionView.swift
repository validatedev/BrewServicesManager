//
//  ServiceInfoStatusSectionView.swift
//  BrewServicesManager
//

import SwiftUI

struct ServiceInfoStatusSectionView: View {
    let info: BrewServiceInfoEntry

    var body: some View {
        PanelSectionCardView(title: "Status") {
            InfoKeyValueRowView(label: "State", value: Text(info.status.displayName))

            if let running = info.running {
                InfoKeyValueRowView(label: "Running", value: Text(running ? "Yes" : "No"))
            }

            if let loaded = info.loaded {
                InfoKeyValueRowView(label: "Loaded", value: Text(loaded ? "Yes" : "No"))
            }

            if let pid = info.pid {
                InfoKeyValueRowView(label: "PID", value: Text(pid, format: .number.grouping(.never)))
            }

            if let exitCode = info.exitCode {
                InfoKeyValueRowView(label: "Exit Code", value: Text(exitCode, format: .number.grouping(.never)))
            }

            if let user = info.user {
                InfoKeyValueRowView(label: "User", value: user)
            }
        }
    }
}
