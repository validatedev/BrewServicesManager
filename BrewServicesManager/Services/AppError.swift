//
//  AppError.swift
//  BrewServicesManager
//

import Foundation

/// Errors that can occur in the application.
nonisolated enum AppError: Error, LocalizedError, Sendable {
    case brewNotFound
    case brewFailed(exitCode: Int32, stderr: String)
    case jsonDecodingFailed(rawOutput: String, underlyingErrorDescription: String)
    case commandTimedOut
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .brewNotFound:
            "Homebrew is not installed or could not be found."
        case .brewFailed(let exitCode, let stderr):
            "Homebrew command failed (exit \(exitCode)): \(stderr)"
        case .jsonDecodingFailed(_, let description):
            "Failed to parse Homebrew output: \(description)"
        case .commandTimedOut:
            "The command timed out."
        case .cancelled:
            "The operation was cancelled."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .brewNotFound:
            "Install Homebrew from https://brew.sh"
        case .brewFailed:
            "Check that the service exists and try again."
        case .jsonDecodingFailed:
            "Try enabling Debug mode or run the command in Terminal to see the raw output."
        case .commandTimedOut:
            "Try the operation again or check if Homebrew is responding."
        case .cancelled:
            nil
        }
    }
}
