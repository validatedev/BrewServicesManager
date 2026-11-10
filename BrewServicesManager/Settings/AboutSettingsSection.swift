//
//  AboutSettingsSection.swift
//  BrewServicesManager
//

import SwiftUI

/// Settings section showing the app version.
struct AboutSettingsSection: View {
    private static let versionDescription: String = {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }()

    var body: some View {
        Section("About") {
            LabeledContent("Version", value: Self.versionDescription)
                .textSelection(.enabled)
        }
    }
}
