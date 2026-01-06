//
//  ServiceInfoPortsSectionView.swift
//  BrewServicesManager
//

import SwiftUI

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
