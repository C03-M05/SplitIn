//
//  ConfigurationAppIntent.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import AppIntents

// Intent konfigurasi yang memungkinkan user memilih group di Edit Widget.
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "SplitIn Group"
    static var description = IntentDescription("Choose the group to show in the widget.")

    @Parameter(title: "Group")
    var group: SplitInWidgetGroupEntity?
}
