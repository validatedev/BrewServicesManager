//
//  BrewServiceStatus.swift
//  BrewServicesManager
//

import Foundation

/// Represents the status of a Homebrew service.
enum BrewServiceStatus: String, Codable, Sendable {
    case started
    case stopped
    case scheduled
    case none
    case error
    case unknown
    
    /// Initialize from a raw string, returning `.unknown` for unrecognized values.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = BrewServiceStatus(rawValue: rawValue) ?? .unknown
    }
    
    /// A human-readable display name.
    nonisolated var displayName: String {
        switch self {
        case .started: "Running"
        case .stopped: "Stopped"
        case .scheduled: "Scheduled"
        case .none: "Not Loaded"
        case .error: "Error"
        case .unknown: "Unknown"
        }
    }
    
    /// SF Symbol name for the status indicator.
    nonisolated var symbolName: String {
        switch self {
        case .started: "circle.fill"
        case .stopped: "circle"
        case .scheduled: "clock"
        case .none: "circle"
        case .error: "exclamationmark.triangle.fill"
        case .unknown: "questionmark.circle"
        }
    }
    
    /// Whether this status indicates the service is actively running.
    nonisolated var isActive: Bool {
        switch self {
        case .started, .scheduled: true
        default: false
        }
    }
}
