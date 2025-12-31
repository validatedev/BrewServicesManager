//
//  ServiceAction.swift
//  BrewServicesManager
//

import Foundation

/// Actions that can be performed on a Homebrew service.
nonisolated enum ServiceAction: Sendable {
    /// Run the service once without registering it.
    case run
    
    /// Start the service and register it to run at login/boot.
    case start
    
    /// Stop the service.
    case stop(keepRegistered: Bool, waitBehavior: StopWaitBehavior = .default)
    
    /// Restart the service.
    case restart
    
    /// Kill the service immediately but keep it registered.
    case kill
    
    /// The brew subcommand for this action.
    var subcommand: String {
        switch self {
        case .run: "run"
        case .start: "start"
        case .stop: "stop"
        case .restart: "restart"
        case .kill: "kill"
        }
    }
    
    /// Additional arguments for this action.
    var additionalArguments: [String] {
        switch self {
        case .stop(let keepRegistered, let waitBehavior):
            var args: [String] = []
            if keepRegistered {
                args.append("--keep")
            }
            args.append(contentsOf: waitBehavior.arguments)
            return args
        default:
            return []
        }
    }
    
    /// Human-readable label for this action.
    var label: String {
        switch self {
        case .run: "Run (one-shot)"
        case .start: "Start at Login"
        case .stop(let keep, _): keep ? "Stop (keep registered)" : "Stop"
        case .restart: "Restart"
        case .kill: "Kill"
        }
    }
}
