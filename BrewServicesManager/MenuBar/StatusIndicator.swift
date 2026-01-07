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

    private var glowColor: Color {
        switch status {
        case .started:
            .green.opacity(0.6)
        case .error:
            .red.opacity(0.4)
        default:
            .clear
        }
    }

    private var glowRadius: CGFloat {
        switch status {
        case .started, .error:
            LayoutConstants.statusIndicatorGlowRadius
        default:
            0
        }
    }

    var body: some View {
        Image(systemName: status.symbolName)
            .foregroundStyle(color)
            .shadow(color: glowColor, radius: glowRadius)
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
