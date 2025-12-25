//
//  SectionContainerModifier.swift
//  BrewServicesManager
//

import SwiftUI

/// A view modifier that styles content as a distinct section container.
/// Uses Liquid Glass on macOS 26+, falls back to materials on earlier versions.
struct SectionContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.glassEffect()
        } else {
            content
                .background(.regularMaterial, in: .rect(cornerRadius: LayoutConstants.sectionContainerCornerRadius))
                .padding(.horizontal, LayoutConstants.sectionContainerHorizontalPadding)
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
