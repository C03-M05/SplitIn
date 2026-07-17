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
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        viewModel.normalizedGroupName.isEmpty
                        ? "Nama Grup, Kosong"
                        : "Nama Grup: \(viewModel.normalizedGroupName)"
                    )
                    .accessibilityHint("Ketuk dua kali untuk mengubah nama grup")

                    GroupMembersSection(
                        members: viewModel.members,
                        onAddMember: {
                            viewModel.beginAddingMember()
                        },
                        onRemoveMember: { member in
                            viewModel.removeMember(id: member.id)
                        }
                    )
                    .accessibilityLabel("Daftar Anggota Group")

                    AddGroupFormStatusView(
                        text: viewModel.formStatusText,
                        canSave: viewModel.canSave
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Status formulir: \(viewModel.formStatusText)")
                    .accessibilityAddTraits(.isHeader)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Group Baru")
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
