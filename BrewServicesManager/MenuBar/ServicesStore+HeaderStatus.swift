//
//  ServicesStore+HeaderStatus.swift
//  BrewServicesManager
//

import Foundation

extension ServicesStore {
    /// The status summarized in the menu header pill, in priority order:
    /// missing Homebrew, then a running bulk operation, refresh, warnings, and errors.
    var headerStatus: HeaderStatus {
        if !isBrewAvailable {
            return .homebrewRequired
        }

        if globalOperation?.status == .running {
            return .operating
        }

        if isRefreshing {
            return .refreshing
        }

        if nonFatalError != nil {
            return .warning
        }

        if case .error = state {
            return .error
        }

        return .ready
    }
}
