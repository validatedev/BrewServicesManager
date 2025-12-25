import Foundation

enum ServicesDiskCache {
    private static let cacheVersion = 2

    struct CachedServices: Codable, Sendable {
        let services: [BrewServiceListEntry]
        let lastRefresh: Date?
    }

    static func load(domain: ServiceDomain) -> CachedServices? {
        let url = cacheURL(domain: domain)

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(CachedServices.self, from: data)
        } catch {
            return nil
        }
    }

    static func save(services: [BrewServiceListEntry], lastRefresh: Date?, domain: ServiceDomain) throws {
        let url = cacheURL(domain: domain)
        let cached = CachedServices(services: services, lastRefresh: lastRefresh)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(cached)

        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try data.write(to: url, options: [.atomic])
    }

    private static func cacheURL(domain: ServiceDomain) -> URL {
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let base = applicationSupport ?? URL(fileURLWithPath: NSTemporaryDirectory())

        let hostIdentifier = (Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName)
            .replacing("/", with: "_")

        let directory = base.appending(path: "BrewServicesManager", directoryHint: .isDirectory)

        let namespacedDirectory = directory
            .appending(path: hostIdentifier, directoryHint: .isDirectory)

        return namespacedDirectory
            .appending(path: "services-cache-v\(cacheVersion)-\(domain.rawValue).json")
    }
}
