//
//  ListGroupCard.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 14/07/26.
//

import SwiftUI

struct ListGroupCard<Destination: View>: View {
    let title: String
    let destination: Destination
    let onTap: (() -> Void)?

    @State
    private var isShowingDestination = false

    init(
        title: String,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.destination = destination()
        self.onTap = nil
    }

    init(
        title: String,
        onTap: @escaping () -> Void
    ) where Destination == EmptyView {
        self.title = title
        self.destination = EmptyView()
        self.onTap = onTap
    }

    var body: some View {
        Button {
            if let onTap {
                onTap()
            } else {
                isShowingDestination = true
            }
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
        .navigationDestination(isPresented: $isShowingDestination) {
            destination
        }
    }

    private var cardContent: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
    }
}

//#Preview("List Group Card") {
//    let dummyGroup = Group(
//        name: "Liburan ke Bali"
//    )
//
//    NavigationStack {
//        ListGroupCard(title: dummyGroup.name) {
//            GroupDetailView(group: dummyGroup)
//        }
//        .padding()
//    }
//    .modelContainer(
//        for: [
//            Group.self,
//            Person.self,
//            GroupMember.self,
//            Bill.self,
//            BillItem.self,
//            ItemSplit.self,
//            Settlement.self
//        ],
//        inMemory: true
//    )
//}
