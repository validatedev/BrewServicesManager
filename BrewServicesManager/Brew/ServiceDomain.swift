//
//  ServiceDomain.swift
//  BrewServicesManager
//

import Foundation

/// The domain in which services operate.
nonisolated enum ServiceDomain: String, CaseIterable, Sendable {
    /// User-level services (~/Library/LaunchAgents).
    case user
    
    /// System-level services (/Library/LaunchDaemons), requires admin.
    case system
    
    /// Human-readable label for display.
    var label: String {
        switch self {
        case .user: "User"
        case .system: "System"
        }
    }
    
    /// Description of what this domain means.
    var description: String {
        switch self {
        case .user: "Services run as your user account"
        case .system: "Services run as root (requires admin)"
        }
    }
    
    /// Whether this domain requires admin privileges.
    var requiresAdmin: Bool {
        self == .system
    }
}
