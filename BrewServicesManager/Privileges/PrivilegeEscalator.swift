//
//  PrivilegeEscalator.swift
//  BrewServicesManager
//

import Foundation
import OSLog

/// Provides privilege escalation for running commands as root.
enum PrivilegeEscalator {
    
    private static let logger = Logger(subsystem: "BrewServicesManager", category: "PrivilegeEscalator")
    
    /// Runs a command with administrator privileges using osascript.
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
        
        // Use osascript to run with admin privileges
        let script = "do shell script \"\(escapeForAppleScript(commandString))\" with administrator privileges"
        
        let osascriptURL = URL(filePath: "/usr/bin/osascript")
        let result = try await CommandExecutor.run(
            osascriptURL,
            arguments: ["-e", script],
            timeout: timeout
        )
        
        // osascript returns the command output in stdout
        // If authorization was denied, it will fail with exit code 1
        if result.exitCode != 0 {
            if result.stderr.contains("User canceled") || result.stderr.contains("(-128)") {
                logger.info("User cancelled authorization")
                throw AppError.cancelled
            }
            logger.error("Privileged command failed: \(result.stderr)")
        }
        
        return result
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
