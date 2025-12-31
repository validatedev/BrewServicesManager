//
//  BrewServiceListEntry.swift
//  BrewServicesManager
//

import Foundation

/// Represents a single service entry from `brew services list --json`.
nonisolated struct BrewServiceListEntry: Codable, Identifiable, Sendable {
    
    /// The name of the formula.
    let name: String
    
    /// The current status of the service.
    let status: BrewServiceStatus
    
    /// The user running the service, if any.
    let user: String?
    
    /// Path to the launchd plist file.
    let file: String?
    
    /// Exit code if the service has an error.
    let exitCode: Int?
    
    // MARK: - Identifiable
    
    var id: String { name }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case name
        case status
        case user
        case file
        case exitCode = "exit_code"
    }
    
    // MARK: - Computed Properties
    
    /// Whether this is a system service (LaunchDaemon).
    var isSystemService: Bool {
        if let file {
            return file.hasPrefix("/Library/LaunchDaemons/")
        }
        return user == "root"
    }
    
    /// A display-friendly name for the service.
    var displayName: String { name }
    
    /// The file URL if a plist file is specified.
    var fileURL: URL? {
        guard let file else { return nil }
        return URL(filePath: file)
    }
}
