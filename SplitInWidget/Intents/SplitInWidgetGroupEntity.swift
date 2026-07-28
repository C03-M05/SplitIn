//
//  SplitInWidgetGroupEntity.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import AppIntents

// Representasi group yang bisa dipilih dari konfigurasi widget.
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
