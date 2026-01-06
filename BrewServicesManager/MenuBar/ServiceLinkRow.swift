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

            Button("Open", systemImage: "arrow.up.forward.square") {
                onOpen()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)

            Button("Edit", systemImage: "pencil") {
                onEdit()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)

            Button("Delete", systemImage: "trash") {
                onDelete()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .foregroundStyle(.red)
        }
    }
}
