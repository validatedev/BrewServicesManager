//
//  AppSettings.swift
//  BrewServicesManager
//

import Foundation
import SwiftUI
import ServiceManagement

/// Observable store for application settings.
/// Uses UserDefaults directly to avoid @Observable/@AppStorage conflict.
@MainActor
@Observable
final class AppSettings {
    
    private let defaults: UserDefaults
    
    // MARK: - Keys
    
    private enum Keys {
        static let selectedDomain = "selectedDomain"
        static let sudoServiceUser = "sudoServiceUser"
        static let debugMode = "debugMode"
        static let autoRefreshInterval = "autoRefreshInterval"
        static let launchAtLogin = "launchAtLogin"
        static let automaticallyCheckForUpdates = "automaticallyCheckForUpdates"
    }
    
    // MARK: - Settings
    
    var selectedDomain: ServiceDomain {
        didSet {
            defaults.set(selectedDomain.rawValue, forKey: Keys.selectedDomain)
        }
    }
    
    var sudoServiceUser: String {
        didSet {
            defaults.set(sudoServiceUser, forKey: Keys.sudoServiceUser)
        }
    }
    
    var debugMode: Bool {
        didSet {
            defaults.set(debugMode, forKey: Keys.debugMode)
        }
    }
    
    var autoRefreshInterval: Int {
        didSet {
            defaults.set(autoRefreshInterval, forKey: Keys.autoRefreshInterval)
        }
    }

    var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            Task { @MainActor in
                await applyLaunchAtLoginSetting()
            }
        }
    }

    private(set) var launchAtLoginError: LaunchAtLoginError?

    /// Whether to automatically check for app updates.
    var automaticallyCheckForUpdates: Bool {
        didSet {
            defaults.set(automaticallyCheckForUpdates, forKey: Keys.automaticallyCheckForUpdates)
        }
    }
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let domainRawValue = defaults.string(forKey: Keys.selectedDomain) ?? ServiceDomain.user.rawValue
        selectedDomain = ServiceDomain(rawValue: domainRawValue) ?? .user
        sudoServiceUser = defaults.string(forKey: Keys.sudoServiceUser) ?? ""
        debugMode = defaults.bool(forKey: Keys.debugMode)
        autoRefreshInterval = defaults.integer(forKey: Keys.autoRefreshInterval)
        launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        // Default to true (opt-in by default)
        automaticallyCheckForUpdates = defaults.object(forKey: Keys.automaticallyCheckForUpdates) as? Bool ?? true

        // Sync with actual system state on launch
        Task { @MainActor in
            await syncLaunchAtLoginState()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Whether a sudo service user is configured.
    var hasSudoServiceUser: Bool {
        !sudoServiceUser.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// The validated sudo service user (nil if empty or invalid).
    var validatedSudoServiceUser: String? {
        let trimmed = sudoServiceUser.trimmingCharacters(in: .whitespaces)
        // Basic validation: no whitespace or special characters
        guard !trimmed.isEmpty,
              !trimmed.contains(where: { $0.isWhitespace || $0.isNewline }) else {
            return nil
        }
        return trimmed
    }

    // MARK: - Launch at Login

    /// Synchronizes the stored preference with the actual system state.
    private func syncLaunchAtLoginState() async {
        let service = SMAppService.mainApp
        let actualStatus = service.status

        switch actualStatus {
        case .enabled:
            // System says enabled, update our stored value if different
            if !launchAtLogin {
                // Update persisted value only, to avoid triggering didSet and side effects
                defaults.set(true, forKey: Keys.launchAtLogin)
            }
        case .notRegistered, .notFound:
            // System says not registered or not found - both mean the login item is not active
            // .notFound can occur when running from Xcode or if the app hasn't been registered yet
            if launchAtLogin {
                // Update persisted value only, to avoid triggering didSet and side effects
                defaults.set(false, forKey: Keys.launchAtLogin)
            }
        case .requiresApproval:
            // User needs to approve in System Settings
            launchAtLoginError = .registrationFailed("Requires approval in System Settings")
        @unknown default:
            // Future-proofing for new status values
            // Don't show an error for unknown statuses, just log it silently
            break
        }
    }

    /// Applies the current launchAtLogin setting to the system.
    private func applyLaunchAtLoginSetting() async {
        // Clear any previous error
        launchAtLoginError = nil

        let service = SMAppService.mainApp

        do {
            if launchAtLogin {
                // Register the app to launch at login
                try await service.register()
            } else {
                // Unregister from launch at login
                try await service.unregister()
            }
        } catch {
            // Handle the error
            if launchAtLogin {
                launchAtLoginError = .registrationFailed(error.localizedDescription)
            } else {
                launchAtLoginError = .unregistrationFailed(error.localizedDescription)
            }

            // Revert the stored setting to match actual state without triggering observers
            let actualEnabled = service.status == .enabled
            defaults.set(actualEnabled, forKey: Keys.launchAtLogin)
        }

        // Check if approval is required
        if service.status == .requiresApproval {
            launchAtLoginError = .registrationFailed("Requires approval in System Settings > General > Login Items")
        }
    }

    /// Manually refresh the launch-at-login status from the system.
    func refreshLaunchAtLoginStatus() async {
        await syncLaunchAtLoginState()
    }
}
