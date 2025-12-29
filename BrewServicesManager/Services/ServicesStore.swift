//
//  ServicesStore.swift
//  BrewServicesManager
//

import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class ServicesStore {
    private let logger = Logger(subsystem: "BrewServicesManager", category: "ServicesStore")
    
    var state: ServicesState = .idle
    
    var nonFatalError: AppError?
    
    var globalOperation: GlobalOperation?
    var serviceOperations: [String: ServiceOperation] = [:]
    
    private let minimumRefreshInterval: TimeInterval = 10
    private var refreshInFlight = false
    private var pendingRefreshRequest: RefreshRequest?
    private var restoredCacheDomains: Set<ServiceDomain> = []
    private var lastRefreshByDomain: [ServiceDomain: Date] = [:]
    private var currentDomain: ServiceDomain?
    
    private struct RefreshRequest: Sendable {
        let domain: ServiceDomain
        let sudoServiceUser: String?
        let debugMode: Bool
        let force: Bool
    }
    
    /// When the services were last refreshed.
    private(set) var lastRefresh: Date?
    
    /// Detailed info for a selected service.
    private(set) var selectedServiceInfo: BrewServiceInfoEntry?
    
    /// The last command diagnostics for debugging.
    private(set) var lastDiagnostics: String?
    
    /// Whether a refresh is currently in progress.
    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    var isRefreshing: Bool {
        refreshInFlight
    }
    
    /// The list of services if loaded.
    var services: [BrewServiceListEntry] {
        switch state {
        case .loaded(let services):
            services
        case .refreshing(let services):
            services
        default:
            []
        }
    }
    
    /// The error if in error state.
    var error: AppError? {
        if case .error(let error) = state { return error }
        return nil
    }
    
    /// Whether Homebrew was found.
    var isBrewAvailable: Bool {
        if case .error(.brewNotFound) = state { return false }
        return true
    }
    
    /// The client for executing brew commands.
    private let client: BrewServicesClientProtocol

    /// The port detector for finding listening ports.
    private let portDetector = PortDetector()

    init(client: BrewServicesClientProtocol = BrewServicesClient()) {
        self.client = client
    }
    
    // MARK: - Actions
    
    /// Refreshes the list of services for the given domain.
    func refresh(
        domain: ServiceDomain = .user,
        sudoServiceUser: String? = nil,
        debugMode: Bool = false,
        force: Bool = false
    ) async {
        if currentDomain != domain {
            currentDomain = domain
            restoreCachedServicesIfNeeded(domain: domain)
        }

        restoreCachedServicesIfNeeded(domain: domain)

        let request = RefreshRequest(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode, force: force)

        if refreshInFlight {
            pendingRefreshRequest = request
            logger.debug("Refresh already in progress, queueing")
            return
        }

        var nextRequest: RefreshRequest? = request
        refreshInFlight = true
        defer { refreshInFlight = false }
        while let current = nextRequest {
            pendingRefreshRequest = nil
            restoreCachedServicesIfNeeded(domain: current.domain)

            if !current.force,
               let lastRefresh = lastRefreshByDomain[current.domain],
               Date().timeIntervalSince(lastRefresh) < minimumRefreshInterval {
                logger.debug("Refresh throttled")
                nextRequest = pendingRefreshRequest
                continue
            }

            let previousState = state
            let existingServices: [BrewServiceListEntry]? = switch previousState {
            case .loaded(let services):
                services
            case .refreshing(let services):
                services
            default:
                nil
            }

            if let existingServices {
                state = .refreshing(existingServices)
            } else {
                state = .loading
            }

            logger.info("Refreshing services list (domain: \(current.domain.rawValue))")

            let domainForRefresh = current.domain
            do {
                let services = try await client.listServices(
                    domain: domainForRefresh,
                    sudoServiceUser: current.sudoServiceUser,
                    debugMode: current.debugMode
                )

                let now = Date()
                lastRefreshByDomain[domainForRefresh] = now
                persistServicesCache(services: services, lastRefresh: now, domain: domainForRefresh)

                if currentDomain == domainForRefresh {
                    state = .loaded(services)
                    lastRefresh = now
                } else {
                    logger.debug("Discarding refresh result for non-selected domain")
                }
                logger.info("Loaded \(services.count) services")
            } catch is CancellationError {
                if currentDomain == domainForRefresh {
                    state = previousState
                }
                logger.debug("Refresh cancelled")
            } catch let error as AppError {
                if case .cancelled = error {
                    if currentDomain == domainForRefresh {
                        state = previousState
                    }
                    logger.debug("Refresh cancelled")
                    nextRequest = pendingRefreshRequest
                    continue
                }

                if let existingServices {
                    if currentDomain == domainForRefresh {
                        state = .loaded(existingServices)
                        nonFatalError = error
                        lastDiagnostics = ServiceOperation.diagnostics(for: error)
                        logger.error("Refresh failed: \(error.localizedDescription)")
                    }
                } else {
                    if currentDomain == domainForRefresh {
                        handleError(error)
                    }
                }
            } catch let error as BrewLocatorError {
                if let existingServices {
                    if currentDomain == domainForRefresh {
                        state = .loaded(existingServices)
                        logger.error("Brew not found: \(error.localizedDescription)")
                    }
                } else {
                    if currentDomain == domainForRefresh {
                        state = .error(.brewNotFound)
                        logger.error("Brew not found: \(error.localizedDescription)")
                    }
                }
            } catch {
                if let existingServices {
                    if currentDomain == domainForRefresh {
                        state = .loaded(existingServices)
                        nonFatalError = .brewFailed(exitCode: -1, stderr: error.localizedDescription)
                        lastDiagnostics = ServiceOperation.diagnostics(for: .brewFailed(exitCode: -1, stderr: error.localizedDescription))
                        logger.error("Unknown error: \(error.localizedDescription)")
                    }
                } else {
                    if currentDomain == domainForRefresh {
                        state = .error(.brewFailed(exitCode: -1, stderr: error.localizedDescription))
                        logger.error("Unknown error: \(error.localizedDescription)")
                    }
                }
            }

            nextRequest = pendingRefreshRequest
        }
    }

    func runAutoRefresh(domain: ServiceDomain, sudoServiceUser: String?, intervalSeconds: Int, debugMode: Bool = false) async {
        await refresh(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode)

        guard intervalSeconds > 0 else {
            return
        }

        while !Task.isCancelled {
            do {
                try await Task.sleep(for: .seconds(intervalSeconds))
            } catch {
                return
            }

            await refresh(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode)
        }
    }
    
    /// Performs an action on a specific service with optimistic UI update.
    func performAction(
        _ action: ServiceAction,
        on service: BrewServiceListEntry,
        domain: ServiceDomain = .user,
        sudoServiceUser: String? = nil,
        debugMode: Bool = false
    ) async {
        logger.info("Performing \(action.subcommand) on \(service.name)")
        serviceOperations[service.id] = ServiceOperation(status: .running, action: action, error: nil, diagnostics: nil)
        
        // Optimistically update UI immediately
        updateServiceStatus(service, for: action)
        
        do {
            try await client.performAction(action, on: service.name, domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode)
            serviceOperations[service.id] = .idle
            // Success - do a quiet background refresh to sync actual state
            await refreshQuietly(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode)
        } catch let error as AppError {
            if case .cancelled = error {
                logger.debug("Action cancelled")
                serviceOperations[service.id] = .idle
                return
            }
            if case .brewNotFound = error {
                handleError(error)
                return
            }
            // On error, refresh to get actual state
            await refresh(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode, force: true)
            recordFailure(error, for: service, action: action)
        } catch {
            await refresh(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode, force: true)
            recordFailure(.brewFailed(exitCode: -1, stderr: error.localizedDescription), for: service, action: action)
            logger.error("Action failed: \(error.localizedDescription)")
        }
    }
    
    /// Updates a service's status optimistically based on the action.
    private func updateServiceStatus(_ service: BrewServiceListEntry, for action: ServiceAction) {
        let existing: [BrewServiceListEntry] = switch state {
        case .loaded(let services):
            services
        case .refreshing(let services):
            services
        default:
            []
        }

        guard !existing.isEmpty else { return }

        var services = existing
        
        guard let index = services.firstIndex(where: { $0.id == service.id }) else { return }
        
        let newStatus: BrewServiceStatus = switch action {
        case .run, .start, .restart:
            .started
        case .stop, .kill:
            .stopped
        }
        
        // Create updated service with new status
        let updated = BrewServiceListEntry(
            name: service.name,
            status: newStatus,
            user: service.user,
            file: service.file,
            exitCode: nil
        )
        
        services[index] = updated
        if case .refreshing = state {
            state = .refreshing(services)
        } else {
            state = .loaded(services)
        }
    }
    
    /// Refreshes without changing loading state (background sync).
    private func refreshQuietly(domain: ServiceDomain, sudoServiceUser: String?, debugMode: Bool) async {
        if isRefreshing {
            pendingRefreshRequest = RefreshRequest(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode, force: true)
            return
        }

        do {
            let services = try await client.listServices(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode)
            state = .loaded(services)
            let now = Date()
            lastRefresh = now
            lastRefreshByDomain[domain] = now
            persistServicesCache(services: services, lastRefresh: now, domain: domain)
        } catch {
            // Silently fail - we already have optimistic state
            logger.debug("Quiet refresh failed: \(error.localizedDescription)")
        }
    }
    
    /// Performs an action on all services and refreshes.
    func performActionOnAll(
        _ action: ServiceAction,
        domain: ServiceDomain = .user,
        sudoServiceUser: String? = nil,
        debugMode: Bool = false
    ) async {
        logger.info("Performing \(action.subcommand) on all services")
        let targets = services
        guard !targets.isEmpty else { return }

        globalOperation = GlobalOperation(
            status: .running,
            title: globalOperationTitle(for: action),
            systemImage: globalOperationSymbolName(for: action),
            completed: 0,
            total: targets.count,
            failed: 0
        )

        var completed = 0
        var failed = 0

        for service in targets {
            serviceOperations[service.id] = ServiceOperation(status: .running, action: action, error: nil, diagnostics: nil)
            updateServiceStatus(service, for: action)

            do {
                try await client.performAction(action, on: service.name, domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode)
                serviceOperations[service.id] = .idle
            } catch let error as AppError {
                if case .cancelled = error {
                    logger.debug("Action cancelled")
                    serviceOperations[service.id] = .idle
                    break
                }
                if case .brewNotFound = error {
                    handleError(error)
                    break
                }
                failed += 1
                recordFailure(error, for: service, action: action)
            } catch {
                failed += 1
                recordFailure(.brewFailed(exitCode: -1, stderr: error.localizedDescription), for: service, action: action)
            }

            completed += 1
            globalOperation = GlobalOperation(
                status: .running,
                title: globalOperationTitle(for: action),
                systemImage: globalOperationSymbolName(for: action),
                completed: completed,
                total: targets.count,
                failed: failed
            )
        }

        if let operation = globalOperation {
            globalOperation = GlobalOperation(
                status: .completed,
                title: operation.title,
                systemImage: operation.systemImage,
                completed: completed,
                total: operation.total,
                failed: failed
            )
        }

        await refresh(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode, force: true)
    }
    
    /// Cleans up unused services.
    func cleanup(domain: ServiceDomain = .user, sudoServiceUser: String? = nil, debugMode: Bool = false) async {
        logger.info("Cleaning up unused services")

        globalOperation = GlobalOperation(
            status: .running,
            title: "Cleaning up",
            systemImage: "trash",
            completed: 0,
            total: 1,
            failed: 0
        )

        do {
            try await client.cleanup(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode)
            globalOperation = GlobalOperation(status: .completed, title: "Cleaning up", systemImage: "trash", completed: 1, total: 1, failed: 0)
            await refresh(domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode, force: true)
        } catch let error as AppError {
            if case .cancelled = error {
                logger.debug("Cleanup cancelled")
                globalOperation = nil
                return
            }
            if case .brewNotFound = error {
                handleError(error)
                return
            }
            globalOperation = GlobalOperation(status: .completed, title: "Cleaning up", systemImage: "trash", completed: 1, total: 1, failed: 1)
            nonFatalError = error
            lastDiagnostics = ServiceOperation.diagnostics(for: error)
        } catch {
            globalOperation = GlobalOperation(status: .completed, title: "Cleaning up", systemImage: "trash", completed: 1, total: 1, failed: 1)
            nonFatalError = .brewFailed(exitCode: -1, stderr: error.localizedDescription)
            lastDiagnostics = ServiceOperation.diagnostics(for: .brewFailed(exitCode: -1, stderr: error.localizedDescription))
            logger.error("Cleanup failed: \(error.localizedDescription)")
        }
    }
    
    /// Fetches detailed info for a service.
    func fetchServiceInfo(
        _ serviceName: String,
        domain: ServiceDomain = .user,
        sudoServiceUser: String? = nil,
        debugMode: Bool = false
    ) async {
        logger.info("Fetching info for \(serviceName)")

        do {
            selectedServiceInfo = try await client.getServiceInfo(serviceName, domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode)
            logger.info("Fetched info for \(serviceName)")
        } catch let error as AppError {
            if case .cancelled = error {
                logger.debug("Fetch info cancelled")
                return
            }
            if case .brewNotFound = error {
                handleError(error)
                return
            }
            nonFatalError = error
            lastDiagnostics = ServiceOperation.diagnostics(for: error)
        } catch {
            nonFatalError = .brewFailed(exitCode: -1, stderr: error.localizedDescription)
            lastDiagnostics = ServiceOperation.diagnostics(for: .brewFailed(exitCode: -1, stderr: error.localizedDescription))
            logger.error("Fetch info failed: \(error.localizedDescription)")
        }
    }

    /// Fetches detailed info for a service including detected ports.
    func fetchServiceInfoWithPorts(
        _ serviceName: String,
        domain: ServiceDomain = .user,
        sudoServiceUser: String? = nil,
        debugMode: Bool = false
    ) async {
        await fetchServiceInfo(serviceName, domain: domain, sudoServiceUser: sudoServiceUser, debugMode: debugMode)

        // Detect ports if service has a PID
        if let info = selectedServiceInfo, let pid = info.pid {
            do {
                let ports = try await portDetector.detectPorts(for: pid)
                // Update the selectedServiceInfo with detected ports
                selectedServiceInfo = info.withDetectedPorts(ports)
                logger.info("Detected \(ports.count) ports for \(serviceName)")
            } catch {
                logger.debug("Port detection failed: \(error.localizedDescription)")
                // Don't fail the whole operation - just log and continue
            }
        }
    }
    
    /// Clears the selected service info.
    func clearServiceInfo() {
        selectedServiceInfo = nil
    }
    
    /// Copies diagnostics to clipboard.
    func copyDiagnosticsToClipboard() {
        guard let diagnostics = lastDiagnostics else { return }
        AppKitBridge.copyToClipboard(diagnostics)
    }

    func copyDiagnosticsToClipboard(for serviceID: String) {
        let diagnostics = serviceOperations[serviceID]?.diagnostics ?? lastDiagnostics
        guard let diagnostics else { return }
        AppKitBridge.copyToClipboard(diagnostics)
    }
    
    // MARK: - Private
    
    private func handleError(_ error: AppError) {
        state = .error(error)
        
        // Store diagnostics for debugging
        lastDiagnostics = ServiceOperation.diagnostics(for: error)
        
        logger.error("Error: \(error.localizedDescription)")
    }

     private func recordFailure(_ error: AppError, for service: BrewServiceListEntry, action: ServiceAction) {
         nonFatalError = error
         lastDiagnostics = ServiceOperation.diagnostics(for: error)
 
         serviceOperations[service.id] = ServiceOperation(
             status: .failed,
             action: action,
             error: error,
             diagnostics: ServiceOperation.diagnostics(for: error)
         )
 
         logger.error("Service operation failed (\(service.name), \(action.subcommand)): \(error.localizedDescription)")
     }

     private func globalOperationTitle(for action: ServiceAction) -> String {
         switch action {
         case .run:
             "Running all"
         case .start:
             "Starting all"
         case .restart:
             "Restarting all"
         case .stop:
             "Stopping all"
         case .kill:
             "Killing all"
         }
     }

     private func globalOperationSymbolName(for action: ServiceAction) -> String {
         switch action {
         case .run:
             "play"
         case .start:
             "play.fill"
         case .restart:
             "arrow.clockwise"
         case .stop:
             "stop.fill"
         case .kill:
             "xmark.octagon.fill"
         }
     }

    private func restoreCachedServicesIfNeeded(domain: ServiceDomain) {
        guard !restoredCacheDomains.contains(domain) else { return }
        restoredCacheDomains.insert(domain)

        if let cached = ServicesDiskCache.load(domain: domain) {
            state = .loaded(cached.services)
            lastRefresh = cached.lastRefresh
            if let cachedRefresh = cached.lastRefresh {
                lastRefreshByDomain[domain] = cachedRefresh
            }
        }
    }

    private func persistServicesCache(services: [BrewServiceListEntry], lastRefresh: Date, domain: ServiceDomain) {
        Task.detached(priority: .utility) {
            await MainActor.run {
                try? ServicesDiskCache.save(services: services, lastRefresh: lastRefresh, domain: domain)
            }
        }
    }
}
