//
//  ConfigurationAppIntent.swift
//  SplitInWidget
//

import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "SplitIn Group"
    static var description = IntentDescription("Choose the group to show in the widget.")

    @Parameter(title: "Group")
    var group: SplitInWidgetGroupEntity?
}
