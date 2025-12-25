//
//  AppKitBridge.swift
//  BrewServicesManager
//

import AppKit

/// Provides isolated AppKit functionality for SwiftUI views.
/// This centralizes AppKit usage to minimize framework mixing.
enum AppKitBridge {
    
    /// Copies a string to the system clipboard.
    static func copyToClipboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }
    
    /// Reveals a file in Finder.
    static func revealInFinder(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// Terminates the application.
    static func quit() {
        NSApplication.shared.terminate(nil)
    }
}
