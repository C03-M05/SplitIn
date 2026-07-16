//
//  AddMemberButton.swift
//  SplitIn
// 
//  Created by ahmadfarhanqf on 15/07/26.
// 

import SwiftUI

struct AddMemberButton: View {
    @ScaledMetric(relativeTo: .body)
    private var avatarSize: CGFloat = 64

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                icon

                Text("Add Member")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: avatarSize + 24)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add group member")
        .accessibilityHint(
            "Opens a dialog to enter a member name."
        )
        .accessibilityIdentifier(
            "addGroup.addMemberButton"
        )
    }

    private var icon: some View {
        ZStack {
            Circle()
                .fill(Color.secondary.opacity(0.08))

            Circle()
                .strokeBorder(
                    Color.secondary.opacity(0.55),
                    style: StrokeStyle(
                        lineWidth: 1.5,
                        dash: [5]
                    )
                )

            Image(systemName: "person.badge.plus")
                .font(.title2)
                .foregroundStyle(.primary)
        }
        .frame(
            width: avatarSize,
            height: avatarSize
        )
        .padding(.horizontal, 10)
        .padding(.top, 8)
    }
}
