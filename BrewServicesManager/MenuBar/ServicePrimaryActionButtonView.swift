import SwiftUI

/// Start or stop button for a service row.
///
/// A single `Button` whose label, icon, and tint vary with the status, so SwiftUI keeps
/// one view identity instead of swapping between two buttons.
struct ServicePrimaryActionButtonView: View {
    let service: BrewServiceListEntry
    let onAction: (ServiceAction) -> Void

    private var isActive: Bool {
        service.status.isActive
    }

    var body: some View {
        Button(isActive ? "Stop" : "Start", systemImage: isActive ? "stop.fill" : "play.fill", action: performPrimaryAction)
            .labelStyle(.iconOnly)
            .foregroundStyle(isActive ? .red : .green)
            .buttonStyle(.plain)
            .help(isActive ? "Stop" : "Start")
    }

    private func performPrimaryAction() {
        onAction(isActive ? .stop(keepRegistered: false) : .start)
    }
}
