//
//  MenuBarHeaderView.swift
//  BrewServicesManager
//

import SwiftUI

/// Header section of the menu bar with gradient accent, title, status, and controls.
struct MenuBarHeaderView: View {
    @Environment(AppSettings.self) private var settings
    
    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: .zero) {
            // Gradient accent bar
            Rectangle()
                .fill(.accentGradient)
                .frame(height: LayoutConstants.accentBarHeight)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Brew Services Manager")
                        .font(.headline)

                    Spacer()

                    MenuHeaderStatusPillView()
                }

                Picker(selection: $settings.selectedDomain) {
                    ForEach(ServiceDomain.allCases, id: \.self) { domain in
                        Text(domain.label).tag(domain)
                    }
                } label: {
                    Label(
                        "Service Domain",
                        systemImage: settings.selectedDomain == .user ? "person" : "lock.shield"
                    )
                    .labelStyle(.iconOnly)
                    .accessibilityLabel(Text(settings.selectedDomain.label))
                }
                .pickerStyle(.segmented)
                .controlSize(.small)
            }
            .padding(.horizontal)
            .padding(.vertical, LayoutConstants.headerVerticalPadding)
        }
    }
}
