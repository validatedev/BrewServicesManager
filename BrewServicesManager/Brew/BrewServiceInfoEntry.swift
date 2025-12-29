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

    // MARK: - Initializer

    init(
        name: String,
        serviceName: String?,
        status: BrewServiceStatus,
        running: Bool?,
        loaded: Bool?,
        schedulable: Bool?,
        pid: Int?,
        exitCode: Int?,
        user: String?,
        file: String?,
        registered: Bool?,
        loadedFile: String?,
        command: String?,
        workingDir: String?,
        rootDir: String?,
        logPath: String?,
        errorLogPath: String?,
        interval: Int?,
        cron: String?,
        detectedPorts: [ServicePort]? = nil
    ) {
        self.name = name
        self.serviceName = serviceName
        self.status = status
        self.running = running
        self.loaded = loaded
        self.schedulable = schedulable
        self.pid = pid
        self.exitCode = exitCode
        self.user = user
        self.file = file
        self.registered = registered
        self.loadedFile = loadedFile
        self.command = command
        self.workingDir = workingDir
        self.rootDir = rootDir
        self.logPath = logPath
        self.errorLogPath = errorLogPath
        self.interval = interval
        self.cron = cron
        self.detectedPorts = detectedPorts
    }

    // Custom Decodable implementation to handle runtime-only detectedPorts
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        serviceName = try container.decodeIfPresent(String.self, forKey: .serviceName)
        status = try container.decode(BrewServiceStatus.self, forKey: .status)
        running = try container.decodeIfPresent(Bool.self, forKey: .running)
        loaded = try container.decodeIfPresent(Bool.self, forKey: .loaded)
        schedulable = try container.decodeIfPresent(Bool.self, forKey: .schedulable)
        pid = try container.decodeIfPresent(Int.self, forKey: .pid)
        exitCode = try container.decodeIfPresent(Int.self, forKey: .exitCode)
        user = try container.decodeIfPresent(String.self, forKey: .user)
        file = try container.decodeIfPresent(String.self, forKey: .file)
        registered = try container.decodeIfPresent(Bool.self, forKey: .registered)
        loadedFile = try container.decodeIfPresent(String.self, forKey: .loadedFile)
        command = try container.decodeIfPresent(String.self, forKey: .command)
        workingDir = try container.decodeIfPresent(String.self, forKey: .workingDir)
        rootDir = try container.decodeIfPresent(String.self, forKey: .rootDir)
        logPath = try container.decodeIfPresent(String.self, forKey: .logPath)
        errorLogPath = try container.decodeIfPresent(String.self, forKey: .errorLogPath)
        interval = try container.decodeIfPresent(Int.self, forKey: .interval)
        cron = try container.decodeIfPresent(String.self, forKey: .cron)

        // Runtime-only property not decoded from JSON
        detectedPorts = nil
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
    let detectedPorts: [ServicePort]?

    /// Returns a new instance with updated detected ports
    func withDetectedPorts(_ ports: [ServicePort]) -> BrewServiceInfoEntry {
        BrewServiceInfoEntry(
            name: name,
            serviceName: serviceName,
            status: status,
            running: running,
            loaded: loaded,
            schedulable: schedulable,
            pid: pid,
            exitCode: exitCode,
            user: user,
            file: file,
            registered: registered,
            loadedFile: loadedFile,
            command: command,
            workingDir: workingDir,
            rootDir: rootDir,
            logPath: logPath,
            errorLogPath: errorLogPath,
            interval: interval,
            cron: cron,
            detectedPorts: ports
        )
    }
}
