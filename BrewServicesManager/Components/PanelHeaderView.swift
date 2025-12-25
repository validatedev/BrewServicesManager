//
//  PanelHeaderView.swift
//  BrewServicesManager
//

import SwiftUI

/// Reusable header for overlay panels (Settings, Service Info, etc.)
struct PanelHeaderView: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button("Back", systemImage: "chevron.left") {
                onBack()
            }
            .labelStyle(.iconOnly)
            .font(.body)
            .buttonStyle(.plain)
            
            Text(title)
                .font(.headline)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, LayoutConstants.headerVerticalPadding)
    }
}

#Preview {
    VStack(spacing: .zero) {
        PanelHeaderView(title: "Settings") { }
        Divider()
        Spacer()
    }
    .frame(width: LayoutConstants.menuWidth, height: LayoutConstants.previewPanelHeight)
}
