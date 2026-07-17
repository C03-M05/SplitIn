//
//  AddGroupToolbar.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 15/07/26.
// 

import SwiftUI

struct AddGroupToolbar: ToolbarContent {
    let canSave: Bool
    let formStatusText: String
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(
            placement: .cancellationAction
        ) {
            Button(action: onCancel) {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Close")
            .accessibilityHint(
                "Closes the add group modal without saving."
            )
            .accessibilityIdentifier(
                "addGroup.closeButton"
            )
        }

        ToolbarItem(
            placement: .principal
        ) {
            Text("Add Group")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
        }

        ToolbarItem(
            placement: .confirmationAction
        ) {
            Button(action: onSave) {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
            }
            .tint(canSave ? .orange : .secondary)
            .disabled(!canSave)
            .accessibilityLabel("Save group")
            .accessibilityHint(
                canSave
                    ? "Saves the group and returns to the start page."
                    : formStatusText
            )
            .accessibilityIdentifier(
                "addGroup.saveButton"
            )
        }
    }
}