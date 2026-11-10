//
//  MenuModalOverlay.swift
//  BrewServicesManager
//

import SwiftUI

/// Dims the menu and floats a panel above it; clicking the dimmed area dismisses.
///
/// Used instead of `.alert`/`.confirmationDialog` because system sheets detach from
/// the `MenuBarExtra` window and can close it when focus moves.
struct MenuModalOverlay<Content: View>: View {
    let onDismiss: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Button(action: onDismiss) {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")

            content
                .background(.regularMaterial, in: .rect(cornerRadius: LayoutConstants.panelCornerRadius))
                .shadow(radius: LayoutConstants.panelShadowRadius)
        }
    }
}
