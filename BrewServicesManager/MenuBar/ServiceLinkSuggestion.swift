//
//  ServiceLinkSuggestion.swift
//  BrewServicesManager
//

import Foundation

/// A link suggested from a detected listening port.
nonisolated struct ServiceLinkSuggestion: Identifiable {
    let port: ServicePort
    let url: URL

    var id: ServicePort.ID { port.id }

    /// Builds suggestions for ports that map to a URL, keeping at most `limit` of them.
    static func suggestions(for ports: [ServicePort], limit: Int = 5) -> [ServiceLinkSuggestion] {
        Array(
            ports
                .lazy
                .compactMap { port in port.suggestedURL.map { ServiceLinkSuggestion(port: port, url: $0) } }
                .prefix(limit)
        )
    }
}
