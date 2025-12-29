//
//  LaunchAtLoginError.swift
//  BrewServicesManager
//

import Foundation

/// Errors that can occur when managing launch-at-login functionality.
enum LaunchAtLoginError: Error, LocalizedError, Sendable {
    case registrationFailed(String)
    case unregistrationFailed(String)
    case statusCheckFailed(String)
    case notSupported

    var errorDescription: String? {
        switch self {
        case .registrationFailed(let details):
            "Failed to enable launch at login: \(details)"
        case .unregistrationFailed(let details):
            "Failed to disable launch at login: \(details)"
        case .statusCheckFailed(let details):
            "Could not check login item status: \(details)"
        case .notSupported:
            "Launch at login is not supported on this system"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .registrationFailed, .unregistrationFailed:
            "Check System Settings > General > Login Items to manage manually, or try restarting the app."
        case .statusCheckFailed:
            "The app will continue to work normally. Try toggling the setting again."
        case .notSupported:
            "This feature requires macOS 13.0 or later."
        }
    }
}
