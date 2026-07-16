//
//  AddGroupView.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 14/07/26.
//

import SwiftData
import SwiftUI

struct AddGroupView: View {
    let onCancel: () -> Void
    let onSaved: () -> Void

    @Environment(\.modelContext)
    private var modelContext

    @State
    private var viewModel = AddGroupViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 28
                ) {
                    GroupNameField(
                        groupName: viewModel.normalizedGroupName,
                        onTap: {
                            viewModel.beginEditingGroupName()
                        }
                    )

                    GroupMembersSection(
                        members: viewModel.members,
                        onAddMember: {
                            viewModel.beginAddingMember()
                        },
                        onRemoveMember: { member in
                            viewModel.removeMember(id: member.id)
                        }
                    )

                    AddGroupFormStatusView(
                        text: viewModel.formStatusText,
                        canSave: viewModel.canSave
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                AddGroupToolbar(
                    canSave: viewModel.canSave,
                    formStatusText: viewModel.formStatusText,
                    onCancel: onCancel,
                    onSave: saveGroup
                )
            }
        }
        .addGroupDialog(viewModel: viewModel)
        .interactiveDismissDisabled(true)
    }

    private func saveGroup() {
        let didSave = viewModel.save(in: modelContext)

        if didSave {
            onSaved()
        }
    }
}

#Preview {
    AddGroupView(
        onCancel: {},
        onSaved: {}
    )
    .modelContainer(
        for: [
            Group.self,
            Person.self,
            GroupMember.self,
            Bill.self,
            BillItem.self,
            ItemSplit.self,
            Settlement.self
        ],
        inMemory: true
    )
}