//
//  ServiceInfoFilesSectionView.swift
//  BrewServicesManager
//

import SwiftUI

struct ServiceInfoFilesSectionView: View {
    let info: BrewServiceInfoEntry

    var body: some View {
        PanelSectionCardView(title: "Files") {
            if let file = info.file {
                ServiceInfoFileRowView(label: "Service File", path: file, url: info.fileURL)
            }

            if let logPath = info.logPath {
                ServiceInfoFileRowView(label: "Log", path: logPath, url: info.logURL)
            }

            if let errorLogPath = info.errorLogPath {
                ServiceInfoFileRowView(label: "Error Log", path: errorLogPath, url: info.errorLogURL)
            }
        }
    }
}
