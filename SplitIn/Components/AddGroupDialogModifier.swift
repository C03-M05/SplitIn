//
//  AddGroupDialogModifier.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 15/07/26.
// 

import SwiftUI

struct AddGroupDialogModifier: ViewModifier {
    @Bindable var viewModel: AddGroupViewModel

    func body(content: Content) -> some View {
        content.alert(
            Text(viewModel.dialogTitle),
            isPresented: dialogPresentationBinding
        ) {
            dialogActions
        } message: {
            Text(viewModel.dialogMessage)
        }
    }

    @ViewBuilder
    private var dialogActions: some View {
        switch viewModel.activeDialog {
        case .some(.groupName):
            groupNameDialog

        case .some(.memberName):
            memberNameDialog

        case .some(.saveError):
            Button(
                "OK",
                role: .cancel
            ) {
                viewModel.dismissDialog()
            }

        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private var groupNameDialog: some View {
        TextField(
            "Group name",
            text: $viewModel.groupNameDraft
        )
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled(false)
        .accessibilityLabel("Group name input")

        Button(
            "Cancel",
            role: .cancel
        ) {
            viewModel.dismissDialog()
        }

        Button("Save") {
            viewModel.commitGroupName()
        }
        .disabled(!viewModel.canCommitGroupName)
        .accessibilityLabel("Save group name")
    }

    @ViewBuilder
    private var memberNameDialog: some View {
        TextField(
            "Member name",
            text: $viewModel.memberNameDraft
        )
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled(false)
        .accessibilityLabel("Member name input")

        Button(
            "Cancel",
            role: .cancel
        ) {
            viewModel.dismissDialog()
        }

        Button("Save") {
            viewModel.commitMemberName()
        }
        .disabled(!viewModel.canCommitMemberName)
        .accessibilityLabel("Save member name")
    }

    private var dialogPresentationBinding: Binding<Bool> {
        Binding(
            get: {
                viewModel.activeDialog != nil
            },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissDialog()
                }
            }
        )
    }
}

extension View {
    func addGroupDialog(
        viewModel: AddGroupViewModel
    ) -> some View {
        modifier(
            AddGroupDialogModifier(
                viewModel: viewModel
            )
        )
    }
}
