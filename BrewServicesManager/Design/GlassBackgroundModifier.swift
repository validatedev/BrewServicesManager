//
//  GlassBackgroundModifier.swift
//  BrewServicesManager
//

import SwiftUI

/// A view modifier that applies version-appropriate glass/material backgrounds.
/// Uses Liquid Glass on macOS 26+, falls back to materials on earlier versions.
struct GlassBackgroundModifier: ViewModifier {
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.glassEffect(in: .rect(cornerRadius: cornerRadius))
        } else {
            content.background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius))
        }
    }
}

extension View {
    /// Applies a glass background effect appropriate for the current macOS version.
    /// - Parameter cornerRadius: The corner radius for the background shape.
    func glassBackground(cornerRadius: CGFloat = LayoutConstants.glassCornerRadius) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack {
        Text("Glass Background")
            .padding()
            .glassBackground()
    }
    .padding()
    .frame(width: LayoutConstants.previewGlassWidth, height: LayoutConstants.previewGlassHeight)
}

