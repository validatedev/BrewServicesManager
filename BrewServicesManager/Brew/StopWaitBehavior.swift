//
//  StopWaitBehavior.swift
//  BrewServicesManager
//

import Foundation

/// Controls how long to wait when stopping a service.
enum StopWaitBehavior: Sendable, Equatable {
    /// Don't wait for the service to stop.
    case noWait
    
    /// Wait up to the specified number of seconds.
    case maxWait(seconds: Int)
    
    /// The default wait behavior (60 seconds).
    nonisolated static var `default`: StopWaitBehavior {
        .maxWait(seconds: 60)
    }
    
    /// Arguments to pass to brew for this behavior.
    nonisolated var arguments: [String] {
        switch self {
        case .noWait:
            ["--no-wait"]
        case .maxWait(let seconds):
            ["--max-wait=\(seconds)"]
        }
    }
}

