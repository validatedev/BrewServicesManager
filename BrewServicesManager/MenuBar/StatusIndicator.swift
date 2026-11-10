//
//  StatusIndicator.swift
//  BrewServicesManager
//

import SwiftUI

/// Displays a status indicator icon for a service.
struct StatusIndicator: View {
    let status: BrewServiceStatus

    private var color: Color {
        switch status {
        case .started:
            .green
        case .stopped, .none:
            .secondary
        case .scheduled:
            .blue
        case .error:
            .red
        case .unknown:
            .orange
        }
    }

    var body: some View {
        Image(systemName: status.symbolName)
            .foregroundStyle(color)
            .accessibilityLabel(Text(status.displayName))
    }
}

#Preview {
    VStack(alignment: .leading) {
        ForEach([BrewServiceStatus.started, .stopped, .scheduled, .none, .error, .unknown], id: \.self) { status in
            HStack {
                StatusIndicator(status: status)
                Text(status.displayName)
            }
        }
    }
    .padding()
}
