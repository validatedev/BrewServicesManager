//
//  HoverHighlightModifier.swift
//  BrewServicesManager
//

import SwiftUI

/// A view modifier that adds a subtle highlight effect on hover.
struct HoverHighlightModifier: ViewModifier {
    let isEnabled: Bool
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .background(isEnabled && isHovered ? Color.primary.opacity(0.08) : Color.clear)
            .clipShape(.rect(cornerRadius: LayoutConstants.hoverCornerRadius))
            .scaleEffect(isEnabled && isHovered ? 1.0 : LayoutConstants.hoverScaleEffect)
            .onHover {
                if isEnabled {
                    isHovered = $0
                } else {
                    isHovered = false
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

extension View {
    /// Adds a subtle highlight effect when the view is hovered.
    func hoverHighlight(isEnabled: Bool = true) -> some View {
        modifier(HoverHighlightModifier(isEnabled: isEnabled))
    }
}

#Preview {
    VStack {
        Text("Hover over me")
            .padding()
            .hoverHighlight()
        
        Text("Also hover here")
            .padding()
            .hoverHighlight()
    }
    .padding()
}
