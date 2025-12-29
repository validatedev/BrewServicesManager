//
//  PortDetector.swift
//  BrewServicesManager
//

import Foundation
import OSLog

/// Detects listening ports for services using lsof
actor PortDetector {
    private let logger = Logger(subsystem: "BrewServicesManager", category: "PortDetector")

    /// Detects listening ports for a service with the given PID, including child processes
    func detectPorts(for pid: Int) async throws -> [ServicePort] {
        // First, get all PIDs in the process tree (parent + children + grandchildren)
        let pids = try await getAllDescendantPIDs(for: pid)

        guard !pids.isEmpty else {
            logger.debug("No processes found for PID \(pid)")
            return []
        }

        // Build comma-separated PID list for lsof
        let pidList = pids.map(String.init).joined(separator: ",")

        let arguments = [
            "-nP",              // No host/port name resolution
            "-iTCP",            // TCP internet files
            "-sTCP:LISTEN",     // Only LISTEN state
            "-a",               // AND the conditions
            "-p", pidList       // For these PIDs
        ]

        logger.info("Detecting ports for PID \(pid) and \(pids.count - 1) descendants")

        let result = try await CommandExecutor.run(
            path: "/usr/sbin/lsof",
            arguments: arguments,
            timeout: .seconds(5)
        )

        guard result.isSuccess else {
            // lsof returns exit code 1 when no results found - this is normal
            if result.exitCode == 1 {
                logger.debug("No listening ports found for PIDs \(pidList)")
                return []
            }
            logger.error("lsof failed: \(result.stderr)")
            throw PortDetectorError.lsofFailed(exitCode: result.exitCode, stderr: result.stderr)
        }

        return parseLsofOutput(result.stdout)
    }

    /// Gets all descendant PIDs (children, grandchildren, etc.) for a given PID
    private func getAllDescendantPIDs(for pid: Int) async throws -> [Int] {
        var allPIDs: Set<Int> = [pid]
        var toCheck: [Int] = [pid]

        // Recursively find all descendants
        while !toCheck.isEmpty {
            let currentPID = toCheck.removeFirst()

            // Find direct children of this PID
            let result = try await CommandExecutor.run(
                path: "/usr/bin/pgrep",
                arguments: ["-P", "\(currentPID)"],
                timeout: .seconds(2)
            )

            guard result.isSuccess else {
                continue
            }

            // Parse PIDs from output
            for line in result.stdout.split(separator: "\n") {
                if let childPID = Int(line.trimmingCharacters(in: .whitespaces)),
                   !allPIDs.contains(childPID) {
                    allPIDs.insert(childPID)
                    toCheck.append(childPID)
                }
            }
        }

        return Array(allPIDs)
    }

    private func parseLsofOutput(_ output: String) -> [ServicePort] {
        var ports: [ServicePort] = []
        var seen: Set<String> = []

        for line in output.split(separator: "\n") {
            // lsof output format: COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
            // Example: postgres 1234 user 5u IPv4 0x123 0t0 TCP *:5432 (LISTEN)
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)

            guard parts.count >= 9,
                  parts[7].hasPrefix("TCP") || parts[7].hasPrefix("UDP") else {
                continue
            }

            let protocolAndAddress = String(parts[8])
            let protocolType: ServicePort.PortProtocol = parts[7].hasPrefix("TCP") ? .tcp : .udp

            // Extract port from address like "*:5432" or "127.0.0.1:8080"
            if let portString = protocolAndAddress.split(separator: ":").last,
               let port = Int(portString) {
                let portId = "\(protocolType.rawValue)-\(port)"
                if !seen.contains(portId) {
                    seen.insert(portId)
                    ports.append(ServicePort(port: port, portProtocol: protocolType))
                }
            }
        }

        return ports.sorted { $0.port < $1.port }
    }
}

enum PortDetectorError: Error, LocalizedError {
    case lsofFailed(exitCode: Int32, stderr: String)
    case noPIDAvailable

    var errorDescription: String? {
        switch self {
        case .lsofFailed(let exitCode, let stderr):
            "Port detection failed (exit \(exitCode)): \(stderr)"
        case .noPIDAvailable:
            "Service is not running (no PID)"
        }
    }
}
