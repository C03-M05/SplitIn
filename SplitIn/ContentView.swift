//
//  ContentView.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            SplitGroupsView(
                onAddGroup: {}
            )
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [
                Group.self,
                Person.self,
                GroupMember.self,
                Bill.self,
                BillItem.self,
                ItemSplit.self,
                Settlement.self
            ],
            inMemory: true
    )
}
