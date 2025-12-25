//
//  BrewServicesDecodingTests.swift
//  BrewServicesManagerTests
//

import Foundation
import Testing
@testable import BrewServicesManager

@MainActor
struct BrewServicesDecodingTests {
    
    // MARK: - BrewServiceListEntry Tests
    
    @Test func decodeValidServiceList() throws {
        let json = """
        [
          {
            "name": "postgresql@16",
            "status": "started",
            "user": "me",
            "file": "/Users/me/Library/LaunchAgents/homebrew.mxcl.postgresql@16.plist",
            "exit_code": null
          },
          {
            "name": "redis",
            "status": "stopped",
            "user": null,
            "file": null,
            "exit_code": null
          }
        ]
        """
        
        let data = Data(json.utf8)
        let services = try JSONDecoder().decode([BrewServiceListEntry].self, from: data)
        
        #expect(services.count == 2)
        
        let postgresql = services[0]
        #expect(postgresql.name == "postgresql@16")
        #expect(postgresql.status == .started)
        #expect(postgresql.user == "me")
        #expect(postgresql.file != nil)
        #expect(postgresql.exitCode == nil)
        #expect(!postgresql.isSystemService)
        
        let redis = services[1]
        #expect(redis.name == "redis")
        #expect(redis.status == .stopped)
        #expect(redis.user == nil)
    }
    
    @Test func decodeServiceWithError() throws {
        let json = """
        [
          {
            "name": "dnsmasq",
            "status": "error",
            "user": "root",
            "file": "/Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist",
            "exit_code": 512
          }
        ]
        """
        
        let data = Data(json.utf8)
        let services = try JSONDecoder().decode([BrewServiceListEntry].self, from: data)
        
        #expect(services.count == 1)
        
        let dnsmasq = services[0]
        #expect(dnsmasq.name == "dnsmasq")
        #expect(dnsmasq.status == .error)
        #expect(dnsmasq.user == "root")
        #expect(dnsmasq.exitCode == 512)
        #expect(dnsmasq.isSystemService)
    }
    
    @Test func decodeUnknownStatus() throws {
        let json = """
        [
          {
            "name": "test-service",
            "status": "some_future_status",
            "user": null,
            "file": null,
            "exit_code": null
          }
        ]
        """
        
        let data = Data(json.utf8)
        let services = try JSONDecoder().decode([BrewServiceListEntry].self, from: data)
        
        #expect(services.count == 1)
        #expect(services[0].status == .unknown)
    }
    
    @Test func decodeEmptyServiceList() throws {
        let json = "[]"
        
        let data = Data(json.utf8)
        let services = try JSONDecoder().decode([BrewServiceListEntry].self, from: data)
        
        #expect(services.isEmpty)
    }
    
    // MARK: - BrewServiceStatus Tests
    
    @Test func serviceStatusProperties() {
        #expect(BrewServiceStatus.started.isActive)
        #expect(BrewServiceStatus.scheduled.isActive)
        #expect(!BrewServiceStatus.stopped.isActive)
        #expect(!BrewServiceStatus.none.isActive)
        #expect(!BrewServiceStatus.error.isActive)
    }
    
    @Test func serviceStatusDisplayNames() {
        #expect(BrewServiceStatus.started.displayName == "Running")
        #expect(BrewServiceStatus.stopped.displayName == "Stopped")
        #expect(BrewServiceStatus.scheduled.displayName == "Scheduled")
        #expect(BrewServiceStatus.none.displayName == "Not Loaded")
        #expect(BrewServiceStatus.error.displayName == "Error")
        #expect(BrewServiceStatus.unknown.displayName == "Unknown")
    }
    
    // MARK: - ServiceAction Tests
    
    @Test func serviceActionSubcommands() {
        #expect(ServiceAction.run.subcommand == "run")
        #expect(ServiceAction.start.subcommand == "start")
        #expect(ServiceAction.restart.subcommand == "restart")
        #expect(ServiceAction.stop(keepRegistered: false).subcommand == "stop")
        #expect(ServiceAction.stop(keepRegistered: true).subcommand == "stop")
        #expect(ServiceAction.kill.subcommand == "kill")
    }
    
    @Test func stopActionKeepFlag() {
        // With keep and default wait behavior
        let stopWithKeep = ServiceAction.stop(keepRegistered: true)
        #expect(stopWithKeep.additionalArguments.contains("--keep"))
        #expect(stopWithKeep.additionalArguments.contains("--max-wait=60"))
        
        // Without keep and default wait behavior
        let stopWithoutKeep = ServiceAction.stop(keepRegistered: false)
        #expect(!stopWithoutKeep.additionalArguments.contains("--keep"))
        #expect(stopWithoutKeep.additionalArguments.contains("--max-wait=60"))
        
        // With no-wait behavior
        let stopNoWait = ServiceAction.stop(keepRegistered: false, waitBehavior: .noWait)
        #expect(stopNoWait.additionalArguments.contains("--no-wait"))
        #expect(!stopNoWait.additionalArguments.contains("--max-wait=60"))
    }
    
    // MARK: - System Service Detection
    
    @Test func detectSystemService() throws {
        let systemServiceJSON = """
        {
            "name": "dnsmasq",
            "status": "started",
            "user": "root",
            "file": "/Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist",
            "exit_code": null
        }
        """
        
        let data = Data(systemServiceJSON.utf8)
        let service = try JSONDecoder().decode(BrewServiceListEntry.self, from: data)
        
        #expect(service.isSystemService)
    }
    
    @Test func detectUserService() throws {
        let userServiceJSON = """
        {
            "name": "postgresql@16",
            "status": "started",
            "user": "me",
            "file": "/Users/me/Library/LaunchAgents/homebrew.mxcl.postgresql@16.plist",
            "exit_code": null
        }
        """
        
        let data = Data(userServiceJSON.utf8)
        let service = try JSONDecoder().decode(BrewServiceListEntry.self, from: data)
        
        #expect(!service.isSystemService)
    }
}

