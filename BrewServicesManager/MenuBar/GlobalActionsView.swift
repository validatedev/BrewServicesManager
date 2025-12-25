//
//  GlobalActionsView.swift
//  BrewServicesManager
//

import SwiftUI

/// Global actions section for the menu bar.
struct GlobalActionsView: View {
    @Environment(ServicesStore.self) private var store
    
    let onAction: (GlobalActionType) -> Void
    
    var body: some View {
        let isEnabled = store.isBrewAvailable && store.globalOperation?.status != .running

        VStack(alignment: .leading, spacing: .zero) {
            MenuRowButton("Start All…", systemImage: "play.fill", isEnabled: isEnabled) {
                onAction(.startAll)
            }

            MenuRowButton("Stop All…", systemImage: "stop.fill", isEnabled: isEnabled) {
                onAction(.stopAll)
            }

            MenuRowButton("Restart All…", systemImage: "arrow.clockwise", isEnabled: isEnabled) {
                onAction(.restartAll)
            }

            MenuRowButton("Cleanup Unused…", systemImage: "trash", isEnabled: isEnabled) {
                onAction(.cleanup)
            }
        }
    }
}
