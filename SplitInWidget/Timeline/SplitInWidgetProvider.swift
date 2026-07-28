//
//  SplitInWidgetProvider.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import AppIntents
import Foundation
import WidgetKit

// Provider timeline yang memuat snapshot sesuai konfigurasi group widget.
struct SplitInWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SplitInWidgetEntry {
        .preview()
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SplitInWidgetEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SplitInWidgetEntry> {
        Timeline(
            entries: [entry(for: configuration)],
            policy: .after(Date().addingTimeInterval(15 * 60))
        )
    }

    private func entry(for configuration: ConfigurationAppIntent) -> SplitInWidgetEntry {
        let snapshot = SplitInWidgetStore.loadSnapshot()
        let selectedID = SplitInWidgetStore.selectedGroupID(from: configuration.group?.id)
        return SplitInWidgetEntry(
            date: .now,
            group: snapshot.group(with: selectedID)
        )
    }
}
