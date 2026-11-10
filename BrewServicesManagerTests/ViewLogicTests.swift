//
//  ViewLogicTests.swift
//  BrewServicesManagerTests
//

import Foundation
import Testing
@testable import BrewServicesManager

@MainActor
struct ServiceLinkValidationTests {
    @Test(arguments: ["http://localhost:8080", "https://example.com", "  http://localhost:3000  ", "postgres://localhost:5432"])
    func acceptsURLsWithAllowedSchemes(input: String) {
        #expect(ServiceLink.validatedURL(from: input) != nil)
    }

    @Test(arguments: ["", "not a url", "javascript:alert(1)", "data:text/html,hi", "FILE:///etc/passwd"])
    func rejectsMissingOrBlockedSchemes(input: String) {
        #expect(ServiceLink.validatedURL(from: input) == nil)
    }

    @Test func normalizesLabels() {
        #expect(ServiceLink.normalizedLabel("   ") == nil)
        #expect(ServiceLink.normalizedLabel(" Admin ") == "Admin")
    }
}

@MainActor
struct ServiceLinkSuggestionTests {
    @Test func skipsPortsWithoutURLsBeforeApplyingLimit() {
        let ports = [
            ServicePort(port: 53, portProtocol: .udp),
            ServicePort(port: 80, portProtocol: .tcp),
            ServicePort(port: 443, portProtocol: .tcp),
            ServicePort(port: 8080, portProtocol: .tcp),
        ]

        let suggestions = ServiceLinkSuggestion.suggestions(for: ports, limit: 2)

        #expect(suggestions.map(\.port.port) == [80, 443])
        #expect(suggestions.last?.url.scheme == "https")
    }
}

@MainActor
struct HeaderStatusTests {
    @Test func reportsMissingHomebrewFirst() {
        let store = ServicesStore()
        store.state = .error(.brewNotFound)
        store.nonFatalError = .brewNotFound

        #expect(store.headerStatus == .homebrewRequired)
    }

    @Test func reportsWarningForNonFatalErrors() {
        let store = ServicesStore()
        store.state = .loaded([])
        store.nonFatalError = .brewFailed(exitCode: 1, stderr: "boom")

        #expect(store.headerStatus == .warning)
    }

    @Test func reportsReadyWhenLoaded() {
        let store = ServicesStore()
        store.state = .loaded([])

        #expect(store.headerStatus == .ready)
    }
}
