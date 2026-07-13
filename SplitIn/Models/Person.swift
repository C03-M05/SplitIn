//
//  Person.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import Foundation
import SwiftData

@Model
final class Person {
    @Attribute(.unique)
    var id: UUID

    var name: String

    @Relationship(
        deleteRule: .cascade,
        inverse: \GroupMember.person
    )
    var memberships: [GroupMember] = []

    init(
        id: UUID = UUID(),
        name: String
    ) {
        self.id = id
        self.name = name
    }
}
