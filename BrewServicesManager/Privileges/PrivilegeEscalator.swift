//
//  PrivilegeEscalator.swift
//  BrewServicesManager
//

import Foundation
import AppKit
import OSLog

/// Provides privilege escalation for running commands as root.
nonisolated enum PrivilegeEscalator {

    private static let logger = Logger(subsystem: "BrewServicesManager", category: "PrivilegeEscalator")
    
    /// Runs a command with administrator privileges using NSAppleScript.
    /// - Parameters:
    ///   - executablePath: The path of the executable to run.
    ///   - arguments: Arguments to pass to the executable.
    ///   - sudoServiceUser: Optional user to run the service as when using sudo.
    /// - Returns: The command result.
    static func runWithPrivileges(
        executablePath: String,
        arguments: [String],
        environment: [String: String] = [:],
        sudoServiceUser: String? = nil,
        timeout: Duration? = nil
    ) async throws -> CommandResult {
        var commandParts: [String] = []

        var effectiveEnvironment = environment
        if effectiveEnvironment["PATH"] == nil {
            effectiveEnvironment["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        }
        if effectiveEnvironment["HOMEBREW_NO_AUTO_UPDATE"] == nil {
            effectiveEnvironment["HOMEBREW_NO_AUTO_UPDATE"] = "1"
        }

        for (key, value) in effectiveEnvironment.sorted(by: { $0.key < $1.key }) {
            commandParts.append("\(key)=\(escapeForShell(value))")
        }

        commandParts.append(escapeForShell(executablePath))
        commandParts.append(contentsOf: arguments.map { escapeForShell($0) })

        // Add sudo service user if specified
        if let user = sudoServiceUser, !user.isEmpty {
            commandParts.append(escapeForShell("--sudo-service-user"))
            commandParts.append(escapeForShell(user))
        }

        let commandString = commandParts.joined(separator: " ")

        logger.info("Running with privileges: \(commandString)")

        // Use NSAppleScript directly instead of command-line osascript
        // This gives us better control over dialog presentation
        let script = "do shell script \"\(escapeForAppleScript(commandString))\" with administrator privileges"

        return try await withCheckedThrowingContinuation { continuation in
            // Run on main actor to ensure proper dialog presentation
            Task { @MainActor in
                guard let appleScript = NSAppleScript(source: script) else {
                    logger.error("Failed to create AppleScript")
                    continuation.resume(throwing: AppError.cancelled)
                    return
                }

                var error: NSDictionary?
                let output = appleScript.executeAndReturnError(&error)

                if let error = error {
                    let errorCode = error["NSAppleScriptErrorNumber"] as? Int ?? -1
                    let errorMessage = error["NSAppleScriptErrorMessage"] as? String ?? "Unknown error"

                    if errorCode == -128 {
                        logger.info("User cancelled authorization")
                        continuation.resume(throwing: AppError.cancelled)
                    } else {
                        logger.error("AppleScript failed: \(errorMessage) (code: \(errorCode))")
                        continuation.resume(returning: CommandResult(
                            executablePath: executablePath,
                            arguments: arguments,
                            stdout: "",
                            stderr: errorMessage,
                            exitCode: Int32(errorCode),
                            wasCancelled: false,
                            duration: .zero
                        ))
                    }
                } else {
                    let outputString = output.stringValue ?? ""
                    logger.info("Privileged command completed successfully")
                    continuation.resume(returning: CommandResult(
                        executablePath: executablePath,
                        arguments: arguments,
                        stdout: outputString,
                        stderr: "",
                        exitCode: 0,
                        wasCancelled: false,
                        duration: .zero
                    ))
                }
            }
        }
    }
    
    /// Escapes a string for use in a shell command.
    private static func escapeForShell(_ string: String) -> String {
        // If the string contains special characters, quote it
        let specialChars = CharacterSet(charactersIn: " \t\n\"'\\$`!*?[]{}()<>|&;")
        if string.unicodeScalars.contains(where: { specialChars.contains($0) }) {
            // Use single quotes and escape any single quotes in the string
            let escaped = string.replacing("'", with: "'\\''")
            return "'\(escaped)'"
        }
        return string
    }

    /// Escapes a string for use in an AppleScript string.
    private static func escapeForAppleScript(_ string: String) -> String {
        // Escape backslashes and double quotes for AppleScript
        string
            .replacing("\\", with: "\\\\")
            .replacing("\"", with: "\\\"")
    }
}
