//
//  ServiceLinkRow.swift
//  BrewServicesManager
//

import SwiftUI

struct ServiceLinkRow: View {
    let link: ServiceLink
    let onOpen: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                Text(link.displayLabel)
                    .font(.caption)
                Text(link.url.absoluteString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            Button("Open", systemImage: "arrow.up.forward.square", action: onOpen)
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)

            Button("Edit", systemImage: "pencil", action: onEdit)
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)

            Button("Delete", systemImage: "trash", action: onDelete)
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .foregroundStyle(.red)
        }
    }
}
