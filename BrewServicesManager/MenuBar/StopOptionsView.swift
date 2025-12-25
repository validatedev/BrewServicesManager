//
//  StopOptionsView.swift
//  BrewServicesManager
//

import SwiftUI

/// A popover/sheet for configuring stop options.
struct StopOptionsView: View {
    let serviceName: String
    let onStop: (Bool, StopWaitBehavior) -> Void
    let onCancel: () -> Void
    
    @State private var keepRegistered = false
    @State private var useNoWait = false
    @State private var maxWaitSeconds = 60
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.sectionSpacing) {
            Text("Stop \(serviceName)")
                .font(.headline)
            
            Toggle("Keep service registered at login/boot", isOn: $keepRegistered)
            
            VStack(alignment: .leading) {
                Text("Wait behavior")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Picker("Wait behavior", selection: $useNoWait) {
                    Text("Wait up to \(maxWaitSeconds) seconds").tag(false)
                    Text("Don't wait").tag(true)
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()
                
                if !useNoWait {
                    HStack {
                        Text("Max wait:")
                        TextField("Seconds", value: $maxWaitSeconds, format: .number)
                            .frame(width: LayoutConstants.secondsFieldWidth)
                        Text("seconds")
                    }
                }
            }
            
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Stop") {
                    let waitBehavior: StopWaitBehavior = useNoWait ? .noWait : .maxWait(seconds: maxWaitSeconds)
                    onStop(keepRegistered, waitBehavior)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: LayoutConstants.menuWidth)
    }
}

#Preview {
    StopOptionsView(
        serviceName: "postgresql@16",
        onStop: { keep, wait in print("Stop with keep=\(keep), wait=\(wait)") },
        onCancel: { print("Cancelled") }
    )
}
