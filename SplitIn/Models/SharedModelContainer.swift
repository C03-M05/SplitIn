//
//  SharedModelContainer.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import SwiftData

enum SharedModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            Group.self,
            Person.self,
            GroupMember.self,
            Bill.self,
            BillItem.self,
            ItemSplit.self,
            Settlement.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError(
                "Could not create ModelContainer: \(error)"
            )
        }
    }()
}
