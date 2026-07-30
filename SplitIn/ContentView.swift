//
//  ContentView.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var pendingCreateBillGroupID: UUID?

    var body: some View {
        NavigationStack {
            SplitGroupsView(
                pendingCreateBillGroupID: $pendingCreateBillGroupID,
                onAddGroup: {}
            )
        }
        .onOpenURL(perform: handleWidgetURL)
    }

    @MainActor
    private func handleWidgetURL(_ url: URL) {
        guard url.scheme == "splitin" else {
            return
        }

        guard url.host == "add-bill" else {
            return
        }

        pendingCreateBillGroupID = Self.groupID(from: url)
    }

    private static func groupID(from url: URL) -> UUID? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let rawGroupID = components?.queryItems?.first { item in
            item.name == "groupID"
        }?.value

        guard let rawGroupID else {
            return nil
        }

        return UUID(uuidString: rawGroupID)
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
