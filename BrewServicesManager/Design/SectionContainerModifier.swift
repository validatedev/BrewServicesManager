//
//  SectionContainerModifier.swift
//  BrewServicesManager
//

import SwiftUI

/// A view modifier that styles content as a distinct section container.
/// Uses Liquid Glass on macOS 26+, falls back to materials on earlier versions.
struct SectionContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        // An explicit shape is required: `glassEffect()` defaults to a capsule,
        // which rounds tall cards into pills and clips their content (issue #6).
        let shape = RoundedRectangle(cornerRadius: LayoutConstants.sectionContainerCornerRadius)

        if #available(macOS 26, *) {
            content.glassEffect(.regular, in: shape)
        } else {
            content.background(.regularMaterial, in: shape)
        }
    }
}

extension View {
    /// Applies section container styling appropriate for the current macOS version.
    func sectionContainer() -> some View {
        modifier(SectionContainerModifier())
    }
}

#Preview {
    VStack {
        VStack {
            Text("Section Content")
            Text("More content")
        }
        .padding()
        .sectionContainer()
    }
    .padding()
    .frame(width: LayoutConstants.previewSectionWidth)
}
