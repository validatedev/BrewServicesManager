//
//  ServiceInfoScheduleSectionView.swift
//  BrewServicesManager
//

import SwiftUI

struct ServiceInfoScheduleSectionView: View {
    let info: BrewServiceInfoEntry

    var body: some View {
        PanelSectionCardView(title: "Schedule") {
            if let schedulable = info.schedulable {
                InfoKeyValueRowView(label: "Schedulable", value: schedulable ? "Yes" : "No")
            }

            if let interval = info.interval {
                InfoKeyValueRowView(label: "Interval", value: "\(interval) seconds")
            }

            if let cron = info.cron {
                InfoKeyValueRowView(label: "Cron", value: cron)
            }
        }
    }
}
