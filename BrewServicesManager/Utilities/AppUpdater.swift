//
//  AppUpdater.swift
//  BrewServicesManager
//

import Combine
import Foundation
import Sparkle

/// Observable wrapper for Sparkle updater.
/// Bridges KVO-based SPUUpdater to @Observable pattern.
@MainActor
@Observable
final class AppUpdater {
    private let updaterController: SPUStandardUpdaterController
    private var cancellables = Set<AnyCancellable>()

    /// Whether the updater is ready to check for updates.
    private(set) var canCheckForUpdates = false

    /// Whether automatic update checks are enabled.
    var automaticallyChecksForUpdates: Bool {
        get { updaterController.updater.automaticallyChecksForUpdates }
        set { updaterController.updater.automaticallyChecksForUpdates = newValue }
    }

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        // Bridge KVO to @Observable
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.canCheckForUpdates = value
            }
            .store(in: &cancellables)
    }

    /// Triggers a user-initiated update check.
    func checkForUpdates() {
        updaterController.updater.checkForUpdates()
    }
}
