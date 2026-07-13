//
//  Group.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import Foundation
import SwiftData

@Model
final class Group {
    @Attribute(.unique)
    var id: UUID

    var name: String
    var createdAt: Date

    @Relationship(
        deleteRule: .cascade,
        inverse: \GroupMember.group
    )
    var members: [GroupMember] = []

    @Relationship(
        deleteRule: .cascade,
        inverse: \Bill.group
    )
    var bills: [Bill] = []

    @Relationship(
        deleteRule: .cascade,
        inverse: \Settlement.group
    )
    var settlements: [Settlement] = []

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}
