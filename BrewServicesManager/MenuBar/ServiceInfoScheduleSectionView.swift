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
                InfoKeyValueRowView(label: "Schedulable", value: Text(schedulable ? "Yes" : "No"))
            }

            if let interval = info.interval {
                InfoKeyValueRowView(
                    label: "Interval",
                    value: Text(Duration.seconds(interval), format: .units(allowed: [.days, .hours, .minutes, .seconds], width: .wide))
                )
            }

            if let cron = info.cron {
                InfoKeyValueRowView(label: "Cron", value: cron)
            }
        }
    }
}
