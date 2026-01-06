//
//  StopWaitBehavior.swift
//  BrewServicesManager
//

import Foundation

/// Controls how long to wait when stopping a service.
nonisolated enum StopWaitBehavior: Sendable, Equatable {
    /// Don't wait for the service to stop.
    case noWait
    
    /// Wait up to the specified number of seconds.
    case maxWait(seconds: Int)
    
    /// The default wait behavior (60 seconds).
    static var `default`: StopWaitBehavior {
        .maxWait(seconds: 60)
    }
    
    /// Arguments to pass to brew for this behavior.
    var arguments: [String] {
        switch self {
        case .noWait:
            ["--no-wait"]
        case .maxWait(let seconds):
            ["--max-wait=\(seconds)"]
        }
    }
}
