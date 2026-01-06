//
//  ServiceLinkSuggestionRow.swift
//  BrewServicesManager
//

import SwiftUI

struct ServiceLinkSuggestionRow: View {
    let url: URL
    let port: ServicePort
    let onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
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
