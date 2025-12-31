//
//  BrewLocator.swift
//  BrewServicesManager
//

import Foundation
import OSLog

/// Locates the Homebrew executable on the system.
nonisolated enum BrewLocator {
    
    private static let logger = Logger(subsystem: "BrewServicesManager", category: "BrewLocator")
    
    /// Common installation paths for Homebrew.
    private static let commonPaths: [String] = [
        "/opt/homebrew/bin/brew",      // Apple Silicon default
        "/usr/local/bin/brew",          // Intel default
        "/home/linuxbrew/.linuxbrew/bin/brew"  // Linux (for completeness)
    ]
    
    /// Attempts to locate the `brew` executable.
    /// - Returns: The URL to the brew executable if found.
    /// - Throws: `BrewLocatorError.brewNotFound` if Homebrew is not installed.
    static func locateBrew() async throws -> URL {
        // First, check common installation paths
        for path in commonPaths {
            let url = URL(filePath: path)
            if FileManager.default.isExecutableFile(atPath: path) {
                logger.info("Found brew at common path: \(path)")
                if await validateBrew(at: url) {
                    return url
                }
            }
        }
        
        // Fall back to `which brew`
        logger.info("Checking PATH for brew using /usr/bin/which")
        if let brewPath = try await findBrewViaWhich() {
            let url = URL(filePath: brewPath)
            if await validateBrew(at: url) {
                return url
            }
        }
        
        logger.error("Homebrew not found on this system")
        throw BrewLocatorError.brewNotFound
    }
    
    /// Validates that the brew executable works by running `brew --version`.
    private static func validateBrew(at url: URL) async -> Bool {
        do {
            let result = try await CommandExecutor.run(url, arguments: ["--version"])
            let isValid = result.isSuccess && result.stdout.contains("Homebrew")
            if isValid {
                logger.info("Validated brew at \(url.path())")
            }
            return isValid
        } catch {
            logger.warning("Failed to validate brew at \(url.path()): \(error.localizedDescription)")
            return false
        }
    }
    
    /// Uses `/usr/bin/which` to find brew in the PATH.
    private static func findBrewViaWhich() async throws -> String? {
        let whichURL = URL(filePath: "/usr/bin/which")
        let environment: [String: String] = [
            "PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        ]
        
        guard FileManager.default.isExecutableFile(atPath: whichURL.path()) else {
            return nil
        }
        
        let result = try await CommandExecutor.run(whichURL, arguments: ["brew"], environment: environment)
        
        guard result.isSuccess else {
            return nil
        }
        
        let path = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        return path.isEmpty ? nil : path
    }
}
