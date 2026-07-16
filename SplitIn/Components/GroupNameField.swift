//
//  GroupNameField.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 15/07/26.
// 

import SwiftUI

struct GroupNameField: View {
    let groupName: String
    let onTap: () -> Void

    private var isEmpty: Bool {
        groupName.isEmpty
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(isEmpty ? "group name" : groupName)
                    .font(.body)
                    .foregroundStyle(
                        isEmpty
                        ? Color.secondary.opacity(0.55)
                        : Color.primary
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

            }
            .padding(.horizontal, 16)
            .frame(
                maxWidth: .infinity,
                minHeight: 52
            )
            .background {
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(Color.secondary.opacity(0.08))
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .stroke(
                    Color.secondary.opacity(0.25),
                    lineWidth: 1
                )
            }
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Group name")
        .accessibilityValue(
            isEmpty ? "Not set" : groupName
        )
        .accessibilityHint(
            "Opens a dialog to enter the group name."
        )
        .accessibilityIdentifier(
            "addGroup.groupNameField"
        )
    }
}
