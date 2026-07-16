//
//  MemberFilterBar.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 16/07/26.
//

import SwiftUI
import SwiftData

struct MemberFilterBar: View {
    let members: [GroupMember]
    let selectedMemberID: UUID?
    let onSelect: (UUID) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(members) { member in
                    let isSelected = selectedMemberID == member.id
                    Button {
                        onSelect(member.id)
                    } label: {
                        Text(member.person.name.lowercased())
                            .font(.bodyText)
                            .foregroundStyle(isSelected ? Color.avatarSelectedText : Color.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(isSelected ? Color.accentOrange : Color.cardBackground)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(member.person.name)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    .accessibilityHint(
                        isSelected
                        ? "Sedang dipilih"
                        : "Ketuk untuk melihat tagihan \(member.person.name)"
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    let container = Seeders.previewContainer()
    let context = container.mainContext
    let groups = try! context.fetch(FetchDescriptor<Group>())
    let group = groups.first ?? Group(name: "Malang Trip")

    return MemberFilterBar(
        members: group.members,
        selectedMemberID: group.members.first?.id,
        onSelect: { _ in }
    )
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
    .modelContainer(container)
}
