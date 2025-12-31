//
//  ServiceLinksStore.swift
//  BrewServicesManager
//

import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class ServiceLinksStore {
    private let logger = Logger(subsystem: "BrewServicesManager", category: "ServiceLinksStore")

    /// Maps service name to its configured links
    private(set) var linksByService: [String: [ServiceLink]] = [:]

    private let storageURL: URL
    private var saveTask: Task<Void, Never>?

    init() {
        // Use same pattern as ServicesDiskCache
        let base = URL.applicationSupportDirectory
        let hostIdentifier = (Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName)
            .replacing("/", with: "_")

        let directory = base
            .appending(path: "BrewServicesManager", directoryHint: .isDirectory)
            .appending(path: hostIdentifier, directoryHint: .isDirectory)

        storageURL = directory.appending(path: "service-links.json")

        Task { await load() }
    }

    func links(for serviceName: String) -> [ServiceLink] {
        linksByService[serviceName] ?? []
    }

    func addLink(_ link: ServiceLink, to serviceName: String) {
        var existing = linksByService[serviceName] ?? []
        existing.append(link)
        linksByService[serviceName] = existing
        save()
    }

    func removeLink(_ linkID: UUID, from serviceName: String) {
        linksByService[serviceName]?.removeAll { $0.id == linkID }
        if linksByService[serviceName]?.isEmpty == true {
            linksByService[serviceName] = nil
        }
        save()
    }

    func updateLink(_ linkID: UUID, in serviceName: String, url: URL, label: String?) {
        guard let index = linksByService[serviceName]?.firstIndex(where: { $0.id == linkID }) else { return }
        linksByService[serviceName]?[index] = ServiceLink(id: linkID, url: url, label: label)
        save()
    }

    private func load() async {
        let storageURL = storageURL
        let loadResult = await Task.detached(priority: .utility) { () -> Result<[String: [ServiceLink]], Error> in
            do {
                let data = try Data(contentsOf: storageURL)
                let decoder = JSONDecoder()
                let decoded = try decoder.decode([String: [ServiceLink]].self, from: data)
                return .success(decoded)
            } catch {
                return .failure(error)
            }
        }.value

        switch loadResult {
        case .success(let decoded):
            linksByService = decoded
            logger.info("Loaded service links for \(self.linksByService.count) services")
        case .failure(let error):
            logger.debug("No existing links file or failed to load: \(error.localizedDescription)")
        }
    }

    private func save() {
        let dataToSave = linksByService
        let previousTask = saveTask

        saveTask = Task.detached(priority: .utility) { [dataToSave, storageURL, previousTask] in
            _ = await previousTask?.result
            let logger = Logger(subsystem: "BrewServicesManager", category: "ServiceLinksStore")
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
                let data = try encoder.encode(dataToSave)

                try FileManager.default.createDirectory(
                    at: storageURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                try data.write(to: storageURL, options: [.atomic])
                logger.debug("Saved service links")
            } catch {
                logger.error("Failed to save links: \(error.localizedDescription)")
            }
        }
    }
}
