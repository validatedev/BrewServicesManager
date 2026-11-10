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
            // Keep one view identity and vary only the opacity, using a system hierarchical fill.
            .background(.quinary.opacity(isEnabled && isHovered ? 1 : 0))
            .clipShape(.rect(cornerRadius: LayoutConstants.hoverCornerRadius))
            .onHover {
                if isEnabled {
                    isHovered = $0
                } else {
                    isHovered = false
                }
            }
            .animation(MotionConstants.hoverHighlight, value: isHovered)
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
