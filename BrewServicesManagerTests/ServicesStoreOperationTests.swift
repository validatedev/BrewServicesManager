import Foundation
import Testing
@testable import BrewServicesManager

@MainActor
struct ServicesStoreOperationTests {
    actor FakeBrewServicesClient: BrewServicesClientProtocol {
        private var services: [BrewServiceListEntry]
        private var failuresByServiceName: [String: AppError] = [:]
        private var performedActions: [(ServiceAction, String)] = []

        init(services: [BrewServiceListEntry]) {
            self.services = services
        }

        func setFailure(_ error: AppError, for serviceName: String) {
            failuresByServiceName[serviceName] = error
        }

        func performedServiceNames() -> [String] {
            performedActions.map { $0.1 }
        }

        func listServices(
            domain: ServiceDomain,
            sudoServiceUser: String?,
            debugMode: Bool
        ) async throws -> [BrewServiceListEntry] {
            services
        }

        func performAction(
            _ action: ServiceAction,
            on serviceName: String,
            domain: ServiceDomain,
            sudoServiceUser: String?,
            debugMode: Bool
        ) async throws {
            performedActions.append((action, serviceName))

            if let error = failuresByServiceName[serviceName] {
                throw error
            }
        }

        func cleanup(
            domain: ServiceDomain,
            sudoServiceUser: String?,
            debugMode: Bool
        ) async throws {
        }

        func getServiceInfo(
            _ serviceName: String,
            domain: ServiceDomain,
            sudoServiceUser: String?,
            debugMode: Bool
        ) async throws -> BrewServiceInfoEntry {
            BrewServiceInfoEntry(
                name: serviceName,
                serviceName: nil,
                status: .unknown,
                running: nil,
                loaded: nil,
                schedulable: nil,
                pid: nil,
                exitCode: nil,
                user: nil,
                file: nil,
                registered: nil,
                loadedFile: nil,
                command: nil,
                workingDir: nil,
                rootDir: nil,
                logPath: nil,
                errorLogPath: nil,
                interval: nil,
                cron: nil
            )
        }
    }

    @Test func singleServiceFailureDoesNotBlockApp() async {
        let okService = BrewServiceListEntry(name: "ok", status: .stopped, user: nil, file: nil, exitCode: nil)
        let failingService = BrewServiceListEntry(name: "fail", status: .stopped, user: nil, file: nil, exitCode: nil)

        let client = FakeBrewServicesClient(services: [okService, failingService])
        await client.setFailure(.brewFailed(exitCode: 1, stderr: "boom"), for: failingService.name)

        let store = ServicesStore(client: client)
        store.state = .loaded([okService, failingService])

        await store.performAction(.start, on: failingService, domain: .user, sudoServiceUser: nil, debugMode: false)

        if case .error = store.state {
            #expect(Bool(false))
        }

        #expect(store.nonFatalError != nil)
        #expect(store.serviceOperations[failingService.id]?.status == .failed)
    }

    @Test func bulkActionContinuesAfterFailure() async {
        let serviceA = BrewServiceListEntry(name: "a", status: .stopped, user: nil, file: nil, exitCode: nil)
        let serviceB = BrewServiceListEntry(name: "b", status: .stopped, user: nil, file: nil, exitCode: nil)

        let client = FakeBrewServicesClient(services: [serviceA, serviceB])
        await client.setFailure(.brewFailed(exitCode: 2, stderr: "nope"), for: serviceA.name)

        let store = ServicesStore(client: client)
        store.state = .loaded([serviceA, serviceB])

        await store.performActionOnAll(.start, domain: .user, sudoServiceUser: nil, debugMode: false)

        let performed = await client.performedServiceNames()
        #expect(performed.contains(serviceA.name))
        #expect(performed.contains(serviceB.name))

        if case .error = store.state {
            #expect(Bool(false))
        }

        #expect(store.nonFatalError != nil)
        #expect(store.serviceOperations[serviceA.id]?.status == .failed)
        #expect(store.serviceOperations[serviceB.id]?.status == .idle)
        #expect(store.globalOperation?.failed == 1)
        #expect(store.globalOperation?.completed == 2)
        #expect(store.globalOperation?.total == 2)
    }
}
