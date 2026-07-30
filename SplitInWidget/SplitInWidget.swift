//
//  SplitInWidget.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import WidgetKit
import SwiftUI

// Mendefinisikan konfigurasi utama widget SplitIn dan family yang didukung.
struct SplitInWidget: Widget {
    let kind = SplitInWidgetStore.widgetKind

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: SplitInWidgetProvider()
        ) { entry in
            SplitInWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SplitIn")
        .description("Shows a selected group and its latest bills.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }
}

#Preview("Small", as: .systemSmall) {
    SplitInWidget()
} timeline: {
    SplitInWidgetEntry.preview()
}

#Preview("Medium", as: .systemMedium) {
    SplitInWidget()
} timeline: {
    SplitInWidgetEntry.preview()
}
