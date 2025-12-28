//
//  BrewServiceInfoEntry.swift
//  BrewServicesManager
//

import Foundation

/// Detailed information about a Homebrew service from `brew services info --json`.
struct BrewServiceInfoEntry: Codable, Identifiable, Hashable, Sendable {
    
    // MARK: - Basic Info
    
    let name: String
    let serviceName: String?
    let status: BrewServiceStatus
    
    // MARK: - State
    
    let running: Bool?
    let loaded: Bool?
    let schedulable: Bool?
    let pid: Int?
    let exitCode: Int?
    let user: String?
    
    // MARK: - Files
    
    let file: String?
    let registered: Bool?
    let loadedFile: String?
    
    // MARK: - Execution Details
    
    let command: String?
    let workingDir: String?
    let rootDir: String?
    
    // MARK: - Logs
    
    let logPath: String?
    let errorLogPath: String?
    
    // MARK: - Scheduling
    
    let interval: Int?
    let cron: String?
    
    // MARK: - Identifiable
    
    var id: String { name }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case name
        case serviceName = "service_name"
        case status
        case running
        case loaded
        case schedulable
        case pid
        case exitCode = "exit_code"
        case user
        case file
        case registered
        case loadedFile = "loaded_file"
        case command
        case workingDir = "working_dir"
        case rootDir = "root_dir"
        case logPath = "log_path"
        case errorLogPath = "error_log_path"
        case interval
        case cron
    }
    
    // MARK: - Computed Properties
    
    var fileURL: URL? {
        guard let file else { return nil }
        return URL(filePath: file)
    }
    
    var logURL: URL? {
        guard let logPath else { return nil }
        return URL(filePath: logPath)
    }
    
    var errorLogURL: URL? {
        guard let errorLogPath else { return nil }
        return URL(filePath: errorLogPath)
    }

    // MARK: - Runtime State (not from JSON)

    /// Detected listening ports (populated at runtime)
    var detectedPorts: [ServicePort]?
}
