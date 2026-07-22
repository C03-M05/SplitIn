//
//  GroupMembersSection.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 15/07/26.
// 

import SwiftUI

struct GroupMembersSection: View {
    let members: [DraftGroupMember]
    let onAddMember: () -> Void
    let onRemoveMember: (DraftGroupMember) -> Void

    private let horizontalMemberSpacing: CGFloat = 4
    private let verticalMemberSpacing: CGFloat = 8

    private var columns: [GridItem] {
        [
            GridItem(
                .adaptive(
                    minimum: 72,
                    maximum: 88
                ),
                spacing: horizontalMemberSpacing,
                alignment: .top
            )
        ]
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("Group Members")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Divider()
                .accessibilityHidden(true)

            if members.isEmpty {
                Text("No members added yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(
                        "No group members have been added."
                    )
            }

            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: verticalMemberSpacing
            ) {
                AddMemberButton(action: onAddMember)

                ForEach(members) { member in
                    MemberAvatarView(
                        member: member,
                        onRemove: {
                            onRemoveMember(member)
                        }
                    )
                }
            }
            .padding(.vertical, 12)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .accessibilityLabel("Group members")
            .accessibilityValue(memberCountAccessibilityValue)
        }
    }

    private var memberCountAccessibilityValue: String {
        switch members.count {
        case 0:
            return "No members added. Minimum two members required."
        case 1:
            return "One member added. Add one more member before saving."
        default:
            return "\(members.count) members added."
        }
    }
}