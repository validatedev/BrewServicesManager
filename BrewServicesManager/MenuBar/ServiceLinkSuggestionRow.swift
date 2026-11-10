//
//  ServiceLinkSuggestionRow.swift
//  BrewServicesManager
//

import SwiftUI

struct ServiceLinkSuggestionRow: View {
    let suggestion: ServiceLinkSuggestion
    let onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                Text(suggestion.url.absoluteString)
                    .font(.caption)
                Text("Port \(suggestion.port.port, format: .number.grouping(.never))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Add", systemImage: "plus.circle.fill", action: onAdd)
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
        }
    }
}
