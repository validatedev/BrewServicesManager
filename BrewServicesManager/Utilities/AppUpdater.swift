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
    private let delegate = AppUpdaterDelegate()
    private var cancellables = Set<AnyCancellable>()

    /// Whether the updater is ready to check for updates.
    private(set) var canCheckForUpdates = false

    /// Whether an update is available and waiting for user attention.
    /// When true, the menu bar icon should show a badge.
    private(set) var hasUpdateWaitingForAttention = false

    /// Whether automatic update checks are enabled.
    var automaticallyChecksForUpdates: Bool {
        get { updaterController.updater.automaticallyChecksForUpdates }
        set { updaterController.updater.automaticallyChecksForUpdates = newValue }
    }

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: delegate
        )

        // Bridge KVO to @Observable
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.canCheckForUpdates = value
            }
            .store(in: &cancellables)

        // Connect delegate callbacks to update observable state
        delegate.onUpdateAvailabilityChanged = { [weak self] hasUpdate in
            self?.hasUpdateWaitingForAttention = hasUpdate
        }

        delegate.onUserViewedUpdate = { [weak self] in
            self?.hasUpdateWaitingForAttention = false
        }
    }

    /// Triggers a user-initiated update check.
    /// Clears the gentle reminder badge since the user is explicitly checking.
    func checkForUpdates() {
        // Clear gentle reminder badge since user is taking action
        hasUpdateWaitingForAttention = false
        updaterController.updater.checkForUpdates()
    }
}
