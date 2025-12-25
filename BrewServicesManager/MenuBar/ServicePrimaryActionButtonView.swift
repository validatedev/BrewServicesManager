import SwiftUI

// MARK: - Primary Action Button

struct ServicePrimaryActionButtonView: View {
    let service: BrewServiceListEntry
    let onAction: (ServiceAction) -> Void

    var body: some View {
        if service.status.isActive {
            Button("Stop", systemImage: "stop.fill") {
                onAction(.stop(keepRegistered: false))
            }
            .labelStyle(.iconOnly)
            .font(.body)
            .foregroundStyle(.red)
            .buttonStyle(.plain)
            .help("Stop")
        } else {
            Button("Start", systemImage: "play.fill") {
                onAction(.start)
            }
            .labelStyle(.iconOnly)
            .font(.body)
            .foregroundStyle(.green)
            .buttonStyle(.plain)
            .help("Start")
        }
    }
}
