import Foundation

protocol BrewServicesClientProtocol: Sendable {
    func listServices(
        domain: ServiceDomain,
        sudoServiceUser: String?,
        debugMode: Bool
    ) async throws -> [BrewServiceListEntry]

    func performAction(
        _ action: ServiceAction,
        on serviceName: String,
        domain: ServiceDomain,
        sudoServiceUser: String?,
        debugMode: Bool
    ) async throws

    func cleanup(
        domain: ServiceDomain,
        sudoServiceUser: String?,
        debugMode: Bool
    ) async throws

    func getServiceInfo(
        _ serviceName: String,
        domain: ServiceDomain,
        sudoServiceUser: String?,
        debugMode: Bool
    ) async throws -> BrewServiceInfoEntry
}
