//
//  MenuSectionLabel.swift
//  BrewServicesManager
//

import SwiftUI

/// A small section header label for visual grouping in the menu.
struct MenuSectionLabel: View {
    let title: LocalizedStringKey
    
    var body: some View {
        Text(title)
            .font(.caption2.weight(.medium))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal)
            .padding(.top, LayoutConstants.sectionLabelTopPadding)
            .padding(.bottom, LayoutConstants.sectionLabelBottomPadding)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: .zero) {
        MenuSectionLabel(title: "Services")
        Text("Service 1").padding(.horizontal)
        Text("Service 2").padding(.horizontal)
        
        MenuSectionLabel(title: "Actions")
        Text("Start All").padding(.horizontal)
        Text("Stop All").padding(.horizontal)
    }
    .frame(width: 250)
}
