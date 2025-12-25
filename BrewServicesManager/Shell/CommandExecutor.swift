//
//  CommandExecutor.swift
//  BrewServicesManager
//

@preconcurrency import Foundation
import os

/// Executes shell commands and captures their output.
enum CommandExecutor {
    
    /// Runs the executable at the given URL with the specified arguments.
    /// - Parameters:
    ///   - executableURL: The URL of the executable to run.
    ///   - arguments: The command-line arguments to pass.
    ///   - environment: Optional environment variables to set.
    ///   - timeout: Optional timeout for the command.
    /// - Returns: A `CommandResult` containing the output and exit status.
    static func run(
        _ executableURL: URL,
        arguments: [String] = [],
        environment: [String: String]? = nil,
        timeout: Duration? = nil
    ) async throws -> CommandResult {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        
        if let environment {
            process.environment = ProcessInfo.processInfo.environment.merging(environment) { _, new in new }
        }
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        let started = ContinuousClock.now
        let stateLock = OSAllocatedUnfairLock(initialState: (didCancel: false, didTimeout: false, didResume: false))

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let finish: @Sendable (Int32) -> Void = { exitCode in
                    let shouldResume = stateLock.withLock { state -> Bool in
                        guard !state.didResume else { return false }
                        state.didResume = true
                        return true
                    }

                    guard shouldResume else { return }
                    
                    let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                    let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                    
                    let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
                    let stderr = String(data: stderrData, encoding: .utf8) ?? ""

                    let (didCancel, didTimeout, _) = stateLock.withLock { state in
                        (state.didCancel, state.didTimeout, state.didResume)
                    }
                    
                    let result = CommandResult(
                        executablePath: executableURL.path(),
                        arguments: arguments,
                        stdout: stdout,
                        stderr: stderr,
                        exitCode: exitCode,
                        wasCancelled: didCancel,
                        duration: started.duration(to: ContinuousClock.now)
                    )
                    
                    if didTimeout {
                        continuation.resume(throwing: CommandExecutorError.timedOut)
                    } else {
                        continuation.resume(returning: result)
                    }
                }
                
                process.terminationHandler = { terminatedProcess in
                    finish(terminatedProcess.terminationStatus)
                }

                do {
                    try process.run()

                    if let timeout {
                        Task {
                            do {
                                try await Task.sleep(for: timeout)
                            } catch {
                                return
                            }

                            let shouldTimeout = stateLock.withLock { state -> Bool in
                                guard !state.didResume else { return false }
                                state.didTimeout = true
                                return true
                            }

                            if shouldTimeout, process.isRunning {
                                process.terminate()
                            }
                        }
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        } onCancel: {
            let shouldCancel = stateLock.withLock { state -> Bool in
                guard !state.didResume else { return false }
                state.didCancel = true
                return true
            }

            if shouldCancel, process.isRunning {
                process.terminate()
            }
        }
    }
    
    /// Runs a command by path string.
    static func run(
        path: String,
        arguments: [String] = [],
        environment: [String: String]? = nil,
        timeout: Duration? = nil
    ) async throws -> CommandResult {
        try await run(URL(filePath: path), arguments: arguments, environment: environment, timeout: timeout)
    }
}
