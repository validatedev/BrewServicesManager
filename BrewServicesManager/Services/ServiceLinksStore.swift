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

    init() {
        // Use same pattern as ServicesDiskCache
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let base = applicationSupport ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let hostIdentifier = (Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName)
            .replacing("/", with: "_")

        let directory = base
            .appending(path: "BrewServicesManager", directoryHint: .isDirectory)
            .appending(path: hostIdentifier, directoryHint: .isDirectory)

        storageURL = directory.appending(path: "service-links.json")

        load()
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

    private func load() {
        do {
            let data = try Data(contentsOf: storageURL)
            let decoder = JSONDecoder()
            linksByService = try decoder.decode([String: [ServiceLink]].self, from: data)
            logger.info("Loaded service links for \(self.linksByService.count) services")
        } catch {
            logger.debug("No existing links file or failed to load: \(error.localizedDescription)")
        }
    }

    private func save() {
        let dataToSave = linksByService

        Task.detached(priority: .utility) { [storageURL, logger] in
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
