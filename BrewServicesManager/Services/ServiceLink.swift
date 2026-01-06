//
//  ServiceLink.swift
//  BrewServicesManager
//

import Foundation

/// A user-configured link for a service
nonisolated struct ServiceLink: Codable, Hashable, Sendable, Identifiable {
    let id: UUID
    let url: URL
    let label: String?

    init(id: UUID = UUID(), url: URL, label: String? = nil) {
        self.id = id
        self.url = url
        self.label = label
    }

    /// Display label (either custom or derived from URL)
    var displayLabel: String {
        label ?? url.host() ?? url.absoluteString
    }
}
