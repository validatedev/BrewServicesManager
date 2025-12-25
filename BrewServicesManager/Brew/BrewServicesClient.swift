//
//  BrewServicesClient.swift
//  BrewServicesManager
//

import Foundation
import OSLog

/// Actor that executes Homebrew service commands serially.
actor BrewServicesClient: BrewServicesClientProtocol {
    
    private let logger = Logger(subsystem: "BrewServicesManager", category: "BrewServicesClient")
    
    /// The resolved path to the brew executable.
    private var brewURL: URL?
    
    /// Environment variables to pass to brew commands.
    private let environment: [String: String] = [
        "HOMEBREW_NO_AUTO_UPDATE": "1"  // Prevent auto-update during JSON commands
    ]
    
    private func mapExecutionError(_ error: Error) -> Error {
        if error is CancellationError {
            return AppError.cancelled
        }

        if let executorError = error as? CommandExecutorError, executorError == .timedOut {
            return AppError.commandTimedOut
        }

        return error
    }

    private func ensureNotCancelled(_ result: CommandResult) throws {
        if result.wasCancelled {
            throw AppError.cancelled
        }
    }
    
    // MARK: - Initialization
    
    /// Ensures brew is located before running commands.
    private func ensureBrewURL() async throws -> URL {
        if let brewURL {
            return brewURL
        }
        
        let url = try await BrewLocator.locateBrew()
        brewURL = url
        return url
    }
    
    // MARK: - Service List
    
    /// Fetches the list of all services for the given domain.
    func listServices(
        domain: ServiceDomain = .user,
        sudoServiceUser: String? = nil,
        debugMode: Bool = false
    ) async throws -> [BrewServiceListEntry] {
        let brewURL = try await ensureBrewURL()
        let arguments = BrewServicesArgumentsBuilder.listArguments(debugMode: debugMode)
        
        logger.info("Running: brew \(arguments.joined(separator: " ")) (domain: \(domain.rawValue))")
        
        let result: CommandResult
        do {
            if domain == .system {
                result = try await PrivilegeEscalator.runWithPrivileges(
                    executablePath: brewURL.path(),
                    arguments: arguments,
                    environment: environment,
                    sudoServiceUser: sudoServiceUser,
                    timeout: .seconds(30)
                )
            } else {
                result = try await CommandExecutor.run(
                    brewURL,
                    arguments: arguments,
                    environment: environment,
                    timeout: .seconds(30)
                )
            }
        } catch {
            throw mapExecutionError(error)
        }

        try ensureNotCancelled(result)
        
        guard result.isSuccess else {
            logger.error("brew services list failed: \(result.stderr)")
            throw AppError.brewFailed(exitCode: result.exitCode, stderr: result.stderr)
        }
        
        return try decodeServices(from: result.stdout)
    }
    
    // MARK: - Service Actions
    
    /// Performs an action on a specific service.
    func performAction(
        _ action: ServiceAction,
        on serviceName: String,
        domain: ServiceDomain = .user,
        sudoServiceUser: String? = nil,
        debugMode: Bool = false
    ) async throws {
        let brewURL = try await ensureBrewURL()
        let arguments = BrewServicesArgumentsBuilder.serviceActionArguments(action: action, serviceName: serviceName, debugMode: debugMode)
        
        logger.info("Running: brew \(arguments.joined(separator: " ")) (domain: \(domain.rawValue))")
        
        let result: CommandResult
        do {
            if domain == .system {
                result = try await PrivilegeEscalator.runWithPrivileges(
                    executablePath: brewURL.path(),
                    arguments: arguments,
                    environment: environment,
                    sudoServiceUser: sudoServiceUser,
                    timeout: .seconds(90)
                )
            } else {
                result = try await CommandExecutor.run(
                    brewURL,
                    arguments: arguments,
                    environment: environment,
                    timeout: .seconds(90)
                )
            }
        } catch {
            throw mapExecutionError(error)
        }

        try ensureNotCancelled(result)
        
        guard result.isSuccess else {
            logger.error("brew \(action.subcommand) \(serviceName) failed: \(result.stderr)")
            throw AppError.brewFailed(exitCode: result.exitCode, stderr: result.stderr)
        }
        
        logger.info("Successfully performed \(action.subcommand) on \(serviceName)")
    }
    
    // MARK: - Global Actions
    
    /// Performs an action on all services.
    func performActionOnAll(
        _ action: ServiceAction,
        domain: ServiceDomain = .user,
        sudoServiceUser: String? = nil,
        debugMode: Bool = false
    ) async throws {
        let brewURL = try await ensureBrewURL()
        let arguments = BrewServicesArgumentsBuilder.allActionArguments(action: action, debugMode: debugMode)
        
        logger.info("Running: brew \(arguments.joined(separator: " ")) (domain: \(domain.rawValue))")
        
        let result: CommandResult
        do {
            if domain == .system {
                result = try await PrivilegeEscalator.runWithPrivileges(
                    executablePath: brewURL.path(),
                    arguments: arguments,
                    environment: environment,
                    sudoServiceUser: sudoServiceUser,
                    timeout: .seconds(90)
                )
            } else {
                result = try await CommandExecutor.run(
                    brewURL,
                    arguments: arguments,
                    environment: environment,
                    timeout: .seconds(90)
                )
            }
        } catch {
            throw mapExecutionError(error)
        }

        try ensureNotCancelled(result)
        
        guard result.isSuccess else {
            logger.error("brew \(action.subcommand) --all failed: \(result.stderr)")
            throw AppError.brewFailed(exitCode: result.exitCode, stderr: result.stderr)
        }
        
        logger.info("Successfully performed \(action.subcommand) on all services")
    }
    
    /// Cleans up unused services.
    func cleanup(domain: ServiceDomain = .user, sudoServiceUser: String? = nil, debugMode: Bool = false) async throws {
        let brewURL = try await ensureBrewURL()
        let arguments = BrewServicesArgumentsBuilder.cleanupArguments(debugMode: debugMode)
        
        logger.info("Running: brew \(arguments.joined(separator: " ")) (domain: \(domain.rawValue))")
        
        let result: CommandResult
        do {
            if domain == .system {
                result = try await PrivilegeEscalator.runWithPrivileges(
                    executablePath: brewURL.path(),
                    arguments: arguments,
                    environment: environment,
                    sudoServiceUser: sudoServiceUser,
                    timeout: .seconds(90)
                )
            } else {
                result = try await CommandExecutor.run(
                    brewURL,
                    arguments: arguments,
                    environment: environment,
                    timeout: .seconds(90)
                )
            }
        } catch {
            throw mapExecutionError(error)
        }

        try ensureNotCancelled(result)
        
        guard result.isSuccess else {
            logger.error("brew services cleanup failed: \(result.stderr)")
            throw AppError.brewFailed(exitCode: result.exitCode, stderr: result.stderr)
        }
        
        logger.info("Successfully cleaned up services")
    }
    
    // MARK: - Service Info
    
    /// Fetches detailed info for a specific service.
    func getServiceInfo(
        _ serviceName: String,
        domain: ServiceDomain = .user,
        sudoServiceUser: String? = nil,
        debugMode: Bool = false
    ) async throws -> BrewServiceInfoEntry {
        let brewURL = try await ensureBrewURL()
        let arguments = BrewServicesArgumentsBuilder.infoArguments(serviceName: serviceName, debugMode: debugMode)
        
        logger.info("Running: brew \(arguments.joined(separator: " ")) (domain: \(domain.rawValue))")
        
        let result: CommandResult
        do {
            if domain == .system {
                result = try await PrivilegeEscalator.runWithPrivileges(
                    executablePath: brewURL.path(),
                    arguments: arguments,
                    environment: environment,
                    sudoServiceUser: sudoServiceUser,
                    timeout: .seconds(30)
                )
            } else {
                result = try await CommandExecutor.run(
                    brewURL,
                    arguments: arguments,
                    environment: environment,
                    timeout: .seconds(30)
                )
            }
        } catch {
            throw mapExecutionError(error)
        }

        try ensureNotCancelled(result)
        
        guard result.isSuccess else {
            logger.error("brew services info failed: \(result.stderr)")
            throw AppError.brewFailed(exitCode: result.exitCode, stderr: result.stderr)
        }
        
        return try decodeServiceInfo(from: result.stdout)
    }
    
    // MARK: - Decoding
    
    private func decodeServices(from jsonString: String) throws -> [BrewServiceListEntry] {
        guard let data = jsonString.data(using: .utf8) else {
            throw AppError.jsonDecodingFailed(
                rawOutput: jsonString,
                underlyingErrorDescription: "Could not convert output to UTF-8 data"
            )
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([BrewServiceListEntry].self, from: data)
        } catch {
            logger.error("JSON decoding failed: \(error.localizedDescription)")
            logger.debug("Raw output: \(jsonString)")
            throw AppError.jsonDecodingFailed(rawOutput: jsonString, underlyingErrorDescription: error.localizedDescription)
        }
    }
    
    private func decodeServiceInfo(from jsonString: String) throws -> BrewServiceInfoEntry {
        guard let data = jsonString.data(using: .utf8) else {
            throw AppError.jsonDecodingFailed(
                rawOutput: jsonString,
                underlyingErrorDescription: "Could not convert output to UTF-8 data"
            )
        }
        
        do {
            let decoder = JSONDecoder()
            // The info command returns an array with one element
            let entries = try decoder.decode([BrewServiceInfoEntry].self, from: data)
            guard let entry = entries.first else {
                throw AppError.jsonDecodingFailed(
                    rawOutput: jsonString,
                    underlyingErrorDescription: "Empty info response"
                )
            }
            return entry
        } catch let error as AppError {
            throw error
        } catch {
            logger.error("JSON decoding failed: \(error.localizedDescription)")
            logger.debug("Raw output: \(jsonString)")
            throw AppError.jsonDecodingFailed(rawOutput: jsonString, underlyingErrorDescription: error.localizedDescription)
        }
    }
}
