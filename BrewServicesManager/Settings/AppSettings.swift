//
//  AppSettings.swift
//  BrewServicesManager
//

import Foundation
import SwiftUI

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

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let domainRawValue = defaults.string(forKey: Keys.selectedDomain) ?? ServiceDomain.user.rawValue
        selectedDomain = ServiceDomain(rawValue: domainRawValue) ?? .user
        sudoServiceUser = defaults.string(forKey: Keys.sudoServiceUser) ?? ""
        debugMode = defaults.bool(forKey: Keys.debugMode)
        autoRefreshInterval = defaults.integer(forKey: Keys.autoRefreshInterval)
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
}
