//
//  SplitGroupsView.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 14/07/26.
//

import SwiftData
import SwiftUI

struct SplitGroupsView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \Group.createdAt,
        order: .reverse
    )
    private var groups: [Group]

    // Ini Closure (Deep Dive lagi terkait Void ini)
    let onAddGroup: () -> Void

    // Ukuran tombol mengikuti pengaturan Dynamic Type.
    @ScaledMetric(relativeTo: .title2)
    private var addButtonSize: CGFloat = 56

    @State
    private var groupBeingEdited: Group?

    @State
    private var groupPendingDeletion: Group?

    @State
    private var editGroupNameDraft = ""

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Your Split Groups")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .accessibilityAddTraits(.isHeader)

                if groups.isEmpty {
                    emptyState
                } else {
                    groupList
                }
            }

            addGroupButton
        }
        .alert(
            "Edit Group",
            isPresented: editGroupPresentationBinding
        ) {
            TextField(
                "Group name",
                text: $editGroupNameDraft
            )
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(false)
            .accessibilityLabel("Group name input")

            Button(
                "Cancel",
                role: .cancel,
                action: cancelEditingGroup
            )

            Button(
                "Save",
                action: saveEditedGroup
            )
            .disabled(normalizedEditGroupName.isEmpty)
            .accessibilityLabel("Save group name")
        } message: {
            Text("Update this group's name.")
        }
        .alert(
            "Delete Group",
            isPresented: deleteGroupPresentationBinding
        ) {
            Button(
                "Cancel",
                role: .cancel,
                action: cancelDeletingGroup
            )

            Button(
                "Delete",
                role: .destructive,
                action: deletePendingGroup
            )
            .accessibilityLabel("Delete group")
        } message: {
            Text(deleteGroupMessage)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack {
            Spacer()

            Text("Add group")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .accessibilityLabel(
                    "No split groups have been added."
                )
                .accessibilityHint(
                    "Use the add group button to create a new group."
                )

            Spacer()
        }
    }

    // MARK: - Group List

    private var groupList: some View {
        List {
                ForEach(
                    groups,
                    id: \.id
                ) { group in
                    ListGroupCard(
                        title: group.name
                    ) {
                        /*
                         Tambahkan navigasi menuju detail grup
                         di sini.

                         Contoh:

                         selectedGroup = group
                         */
                    }
                    .swipeActions(
                        edge: .leading,
                        allowsFullSwipe: true
                    ) {
                        Button {
                            beginEditing(group)
                        } label: {
                            Label(
                                "Edit",
                                systemImage: "pencil"
                            )
                        }
                        .tint(.blue)
                        .accessibilityLabel(
                            "Edit \(group.name)"
                        )
                    }
                    .swipeActions(
                        edge: .trailing,
                        allowsFullSwipe: true
                    ) {
                        Button(
                            role: .destructive
                        ) {
                            beginDeleting(group)
                        } label: {
                            Label(
                                "Delete",
                                systemImage: "trash"
                            )
                        }
                        .accessibilityLabel(
                            "Delete \(group.name)"
                        )
                    }
                    .listRowInsets(
                        EdgeInsets(
                            top: 6,
                            leading: 24,
                            bottom: 6,
                            trailing: 24
                        )
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .accessibilityElement(
                        children: .combine
                    )
                    .accessibilityLabel(
                        "\(group.name), \(memberCountText(for: group))"
                    )
                    .accessibilityHint(
                        "Opens the group details. Swipe right to edit or swipe left to delete."
                    )
                    .accessibilityAction(
                        named: "Edit group"
                    ) {
                        beginEditing(group)
                    }
                    .accessibilityAction(
                        named: "Delete group"
                    ) {
                        beginDeleting(group)
                    }
                }

            // Memberikan ruang agar card terakhir
            // tidak tertutup tombol tambah.
            Color.clear
                .frame(
                    height: addButtonSize + 40
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .accessibilityHidden(true)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.top, 18)
    }

    // MARK: - Add Group Button

    private var addGroupButton: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Button(
                    action: onAddGroup
                ) {
                    Image(systemName: "plus")
                        .font(
                            .title2.weight(.semibold)
                        )
                        .foregroundStyle(.black)
                        .frame(
                            width: addButtonSize,
                            height: addButtonSize
                        )
                        .contentShape(Circle())
                        .accessibilityHidden(true)
                }
                .buttonStyle(
                    .glass(
                        .regular.tint(.orange)
                    )
                )
                .buttonBorderShape(.circle)
                .tint(.orange)
                .accessibilityLabel("Add group")
                .accessibilityHint(
                    "Opens a form to create a new split group."
                )
                .accessibilityInputLabels([
                    "Add group",
                    "Add",
                    "New group"
                ])
                .accessibilityIdentifier(
                    "splitGroups.addGroupButton"
                )
                .padding(.trailing, 24)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Helpers

    private func memberCountText(
        for group: Group
    ) -> String {
        let count = group.members.count

        if count == 1 {
            return "1 member"
        }

        return "\(count) members"
    }

    private var normalizedEditGroupName: String {
        editGroupNameDraft.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var deleteGroupMessage: String {
        guard let groupPendingDeletion else {
            return "This group will be permanently deleted."
        }

        return "\(groupPendingDeletion.name) will be permanently deleted."
    }

    private var editGroupPresentationBinding: Binding<Bool> {
        Binding(
            get: {
                groupBeingEdited != nil
            },
            set: { isPresented in
                if !isPresented {
                    cancelEditingGroup()
                }
            }
        )
    }

    private var deleteGroupPresentationBinding: Binding<Bool> {
        Binding(
            get: {
                groupPendingDeletion != nil
            },
            set: { isPresented in
                if !isPresented {
                    cancelDeletingGroup()
                }
            }
        )
    }

    private func beginEditing(_ group: Group) {
        groupBeingEdited = group
        editGroupNameDraft = group.name
    }

    private func saveEditedGroup() {
        guard let groupBeingEdited else {
            return
        }

        let newName = normalizedEditGroupName

        guard !newName.isEmpty else {
            return
        }

        GroupFactory.renameGroup(
            groupBeingEdited,
            to: newName
        )

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
        }

        cancelEditingGroup()
    }

    private func cancelEditingGroup() {
        groupBeingEdited = nil
        editGroupNameDraft = ""
    }

    private func beginDeleting(_ group: Group) {
        groupPendingDeletion = group
    }

    private func deletePendingGroup() {
        guard let groupPendingDeletion else {
            return
        }

        modelContext.delete(groupPendingDeletion)

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
        }

        cancelDeletingGroup()
    }

    private func cancelDeletingGroup() {
        groupPendingDeletion = nil
    }
}

#Preview("Default") {
    NavigationStack {
        SplitGroupsView(
            onAddGroup: {}
        )
    }
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
