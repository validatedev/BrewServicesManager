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
        // Common HTTP ports
        if port == 80 || (port >= 3000 && port < 10000) {
            return URL(string: "http://localhost:\(port)")
        }
        // Common HTTPS ports
        if port == 443 || port == 8443 {
            return URL(string: "https://localhost:\(port)")
        }
        return URL(string: "http://localhost:\(port)")
    }
}
