//
//  AddGroupFormStatusView.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 15/07/26.
// 

import SwiftUI

struct AddGroupFormStatusView: View {
    let text: String
    let canSave: Bool

    var body: some View {
        Label(
            text,
            systemImage: canSave
            ? "checkmark.circle"
            : "info.circle"
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(
            "addGroup.formStatus"
        )
    }
}
