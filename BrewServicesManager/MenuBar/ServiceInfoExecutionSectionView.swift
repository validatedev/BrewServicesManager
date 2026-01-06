//
//  ServiceInfoExecutionSectionView.swift
//  BrewServicesManager
//

import SwiftUI

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
