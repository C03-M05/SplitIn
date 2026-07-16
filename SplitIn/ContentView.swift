//
//  ContentView.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State
    private var isShowingAddGroup = false

    var body: some View {
        NavigationStack {
            SplitGroupsView(
                onAddGroup: showAddGroup
            )
        }
        .sheet(
            isPresented: $isShowingAddGroup
        ) {
            AddGroupView(
                onCancel: dismissAddGroup,
                onSaved: dismissAddGroup
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .preferredColorScheme(.light)
    }

    private func showAddGroup() {
        isShowingAddGroup = true
    }

    private func dismissAddGroup() {
        isShowingAddGroup = false
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
