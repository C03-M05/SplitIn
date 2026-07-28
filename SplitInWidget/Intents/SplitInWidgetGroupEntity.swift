//
//  SplitInWidgetGroupEntity.swift
//  SplitInWidget
//

import AppIntents

struct SplitInWidgetGroupEntity: AppEntity, Identifiable, Hashable {
    static let placeholderID = "placeholder"
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Group")
    static var defaultQuery = SplitInWidgetGroupQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}
