//
//  PanelHeaderView.swift
//  BrewServicesManager
//

import SwiftUI

/// Reusable header for overlay panels (Settings, Service Info, etc.)
struct PanelHeaderView: View {
    /// Pass `Text("Key")` for localized titles, or `Text(variable)` for runtime values such as service names.
    let title: Text
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button("Back", systemImage: "chevron.left", action: onBack)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)

            title
                .font(.headline)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, LayoutConstants.headerVerticalPadding)
    }
}

#Preview {
    VStack(spacing: .zero) {
        PanelHeaderView(title: Text("Settings")) { }
        Divider()
        Spacer()
    }
    .frame(width: LayoutConstants.menuWidth, height: LayoutConstants.previewPanelHeight)
}
