//
//  CreateBillToolbar.swift
//  SplitIn
//

import SwiftUI

struct CreateBillToolbar: ToolbarContent {
    let title: String
    let canSave: Bool
    @Binding var isShowingDiscardConfirmation: Bool
    let onCancel: () -> Void
    let onDiscardDraft: () -> Void
    let onSave: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: onCancel) {
                Image(systemName: "xmark")
            }
            .confirmationDialog(
                "You have unsaved changes.",
                isPresented: $isShowingDiscardConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Draft", role: .destructive, action: onDiscardDraft)
                Button("Keep Editing", role: .cancel) { }
            } message: {
                Text("Delete or keep editing?")
            }
            .accessibilityLabel("Close")
            .accessibilityHint("Closes the bill form without saving.")
            .accessibilityIdentifier("createBill.closeButton")
        }

        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(action: onSave) {
                Image(systemName: "checkmark")
                    .foregroundStyle(canSave ? Color.white : Color.black)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!canSave)
            .accessibilityLabel("Save bill")
            .accessibilityHint(
                canSave
                ? "Saves the bill and returns to the group."
                : "Fill in the bill name and items to enable saving."
            )
            .accessibilityIdentifier("createBill.saveButton")
        }
    }
}
