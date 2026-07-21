//
//  MemberAvatarView.swift
//  SplitIn
//

import SwiftUI

struct MemberAvatarView: View {
    @ScaledMetric(relativeTo: .body)
    private var avatarSize: CGFloat = 64

    let member: DraftGroupMember
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                avatar
                removeButton
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)

            Text(member.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: avatarSize + 24)
                .accessibilityLabel(
                    "Member \(member.name)"
                )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "addGroup.member.\(member.id)"
        )
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.secondary.opacity(0.14))
                .glassEffect()

            Text(member.initial)
                .font(.title2.bold())
                .foregroundStyle(.primary)
        }
        .frame(
            width: avatarSize,
            height: avatarSize
        )
        .accessibilityHidden(true)
    }

    private var removeButton: some View {
        Button(
            role: .destructive,
            action: onRemove
        ) {
            Image(systemName: "minus.circle.fill")
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .frame(
                    width: 44,
                    height: 44
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .offset(x: 15, y: -15)
        .accessibilityLabel(
            "Remove \(member.name)"
        )
        .accessibilityHint(
            "Removes this member from the group."
        )
        .accessibilityIdentifier(
            "addGroup.removeMember.\(member.id)"
        )
    }
}

#Preview {
    MemberAvatarView(
        member: DraftGroupMember(name: "Ahmad"),
        onRemove: {}
    )
}
