//
//  MotionConstants.swift
//  BrewServicesManager
//

import SwiftUI

/// Shared animation timings and transitions, so motion feels uniform across panels.
enum MotionConstants {
    /// Animation used when pushing or popping an overlay panel.
    static let panelTransition: Animation = .easeInOut(duration: 0.2)

    /// Animation used for row hover highlights.
    static let hoverHighlight: Animation = .easeInOut(duration: 0.15)

    /// Slides panels in from the trailing edge, or cross-fades when Reduce Motion is on.
    static func panelEdgeTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .move(edge: .trailing)
    }
}
