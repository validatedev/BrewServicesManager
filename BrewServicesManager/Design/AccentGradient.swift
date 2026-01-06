//
//  AccentGradient.swift
//  BrewServicesManager
//

import SwiftUI

/// The app's primary accent gradient for branding elements.
/// Provides a warm amber gradient for headers and progress indicators.
enum AccentGradient {
    /// Primary brand color (#FBB040)
    static let brandColor = Color(red: 251/255, green: 176/255, blue: 64/255)
    
    /// The primary brand gradient colors.
    static let colors: [Color] = [
        brandColor.opacity(0.8),
        brandColor,
        brandColor.opacity(0.8)
    ]
    
    /// A linear gradient for horizontal accent bars.
    static var horizontal: LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// A linear gradient for vertical elements.
    static var vertical: LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension ShapeStyle where Self == LinearGradient {
    /// The app's accent gradient for use with shape styles.
    static var accentGradient: LinearGradient {
        AccentGradient.horizontal
    }
}

#Preview {
    VStack(spacing: LayoutConstants.previewSpacing) {
        RoundedRectangle(cornerRadius: 4)
            .fill(.accentGradient)
            .frame(height: 4)
        
        RoundedRectangle(cornerRadius: 8)
            .fill(AccentGradient.vertical)
            .frame(width: 100, height: 100)
    }
    .padding()
}
