//
//  CommandResult.swift
//  BrewServicesManager
//

import Foundation

/// Contains the result of executing a shell command.
nonisolated struct CommandResult: Sendable {
    let executablePath: String
    let arguments: [String]
    let stdout: String
    let stderr: String
    let exitCode: Int32
    let wasCancelled: Bool
    let duration: Duration
    
    /// Whether the command completed successfully (exit code 0).
    var isSuccess: Bool {
        exitCode == 0 && !wasCancelled
    }
}
