//
//  ConfirmationDialogModifier.swift
//  BrewServicesManager
//

import SwiftUI

/// Types of global actions that require confirmation.
enum GlobalActionType: Identifiable {
    case startAll
    case stopAll
    case restartAll
    case cleanup
    
    var id: String {
        switch self {
        case .startAll: "startAll"
        case .stopAll: "stopAll"
        case .restartAll: "restartAll"
        case .cleanup: "cleanup"
        }
    }
    
    var title: String {
        switch self {
        case .startAll: "Start All Services"
        case .stopAll: "Stop All Services"
        case .restartAll: "Restart All Services"
        case .cleanup: "Cleanup Unused Services"
        }
    }
    
    var message: String {
        switch self {
        case .startAll:
            "This will start all Homebrew services and register them to run at login."
        case .stopAll:
            "This will stop all running Homebrew services."
        case .restartAll:
            "This will restart all Homebrew services."
        case .cleanup:
            "This will remove all unused service files."
        }
    }
    
    var confirmButtonTitle: String {
        switch self {
        case .startAll: "Start All"
        case .stopAll: "Stop All"
        case .restartAll: "Restart All"
        case .cleanup: "Cleanup"
        }
    }
    
    var systemImage: String {
        switch self {
        case .startAll: "play.fill"
        case .stopAll: "stop.fill"
        case .restartAll: "arrow.clockwise"
        case .cleanup: "trash"
        }
    }
}
