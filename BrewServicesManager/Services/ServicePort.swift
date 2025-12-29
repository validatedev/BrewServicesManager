//
//  ServicePort.swift
//  BrewServicesManager
//

import Foundation

/// Represents a listening port for a service
struct ServicePort: Codable, Hashable, Sendable, Identifiable {
    let port: Int
    let portProtocol: PortProtocol

    var id: String { "\(portProtocol.rawValue)-\(port)" }

    enum PortProtocol: String, Codable, Sendable {
        case tcp = "TCP"
        case udp = "UDP"
    }

    /// Suggested URL for this port (for HTTP services)
    var suggestedURL: URL? {
        guard portProtocol == .tcp else { return nil }

        // Use HTTPS for common secure ports
        if port == 443 || port == 8443 {
            return URL(string: "https://localhost:\(port)")
        }

        // Default to HTTP for all other TCP ports
        return URL(string: "http://localhost:\(port)")
    }
}
