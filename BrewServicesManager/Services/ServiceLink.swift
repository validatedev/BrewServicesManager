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

    /// URL schemes that are never accepted for user-entered links.
    private static let blockedSchemes: Set<String> = ["javascript", "data", "file"]

    /// Parses user input into a link URL, rejecting input without a scheme or with a blocked scheme.
    static func validatedURL(from input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard let url = URL(string: trimmed), let scheme = url.scheme?.lowercased() else {
            return nil
        }
        return blockedSchemes.contains(scheme) ? nil : url
    }

    /// Normalizes a user-entered label: whitespace-only input means "no custom label".
    static func normalizedLabel(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }
}
