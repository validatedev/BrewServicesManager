//
//  StatusBadge.swift
//  BrewServicesManager
//

import SwiftUI

/// A pill-shaped badge displaying a service status.
struct StatusBadge: View {
    let status: BrewServiceStatus
    
    private var foregroundColor: Color {
        switch status {
        case .started:
            .white
        case .error:
            .white
        case .scheduled:
            .white
        default:
            .primary
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .started:
            .green
        case .stopped, .none:
            .secondary.opacity(0.3)
        case .scheduled:
            .blue
        case .error:
            .red
        case .unknown:
            .orange.opacity(0.6)
        }
    }

    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .bold()
            .padding(.horizontal, LayoutConstants.statusBadgeHorizontalPadding)
            .padding(.vertical, LayoutConstants.statusBadgeVerticalPadding)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor, in: .capsule)
    }
}

#Preview {
    VStack {
        StatusBadge(status: .started)
        StatusBadge(status: .stopped)
        StatusBadge(status: .scheduled)
        StatusBadge(status: .none)
        StatusBadge(status: .error)
        StatusBadge(status: .unknown)
    }
    .padding()
}
