//
//  SplitGroupsView.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 14/07/26.
//

import SwiftData
import SwiftUI

struct GroupNavigationTarget: Identifiable, Hashable {
    let group: Group
    let openCreateBillOnAppear: Bool
    var id: UUID { group.id }
    
    static func == (lhs: GroupNavigationTarget, rhs: GroupNavigationTarget) -> Bool {
           lhs.id == rhs.id && lhs.openCreateBillOnAppear == rhs.openCreateBillOnAppear
       }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(openCreateBillOnAppear)
    }
}

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

    @State private var selectedGroup: GroupNavigationTarget?

    @State private var showAddGroup = false

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
        .sheet(item: $groupBeingEdited) { group in
            AddGroupView(
                group: group,
                onCancel: { groupBeingEdited = nil },
                onSaved: { _ in groupBeingEdited = nil }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showAddGroup) {
            AddGroupView(
                onCancel: { showAddGroup = false },
                onSaved: { newGroup in
                    showAddGroup = false
                    selectedGroup = GroupNavigationTarget(group: newGroup, openCreateBillOnAppear: true)
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
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
        .navigationDestination(item: $selectedGroup) { target in
            GroupDetailView(
                viewModel: GroupDetailViewModel(group: target.group),
                openCreateBillOnAppear: target.openCreateBillOnAppear
            )
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
            ForEach(groups, id: \.id) { group in
                groupRow(for: group)
            }

            Color.clear
                .frame(height: addButtonSize + 40)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .accessibilityHidden(true)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.top, 18)
    }

    private func groupRow(for group: Group) -> some View {
        ListGroupCard(title: group.name, onTap: {
            selectedGroup = GroupNavigationTarget(group: group, openCreateBillOnAppear: false)
        })
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button { beginEditing(group) } label: { Image(systemName: "pencil") }
                .tint(.blue)
                .accessibilityLabel("Edit \(group.name)")
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) { beginDeleting(group) } label: { Image(systemName: "trash") }
                .accessibilityLabel("Delete \(group.name)")
        }
        .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(group.name), \(memberCountText(for: group))")
        .accessibilityHint("Opens the group details. Edit and delete are available as actions.")
    }

    // MARK: - Add Group Button

    private var addGroupButton: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Button(
                    action: {
                        onAddGroup()
                        showAddGroup = true 
                    }
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

    private var deleteGroupMessage: String {
        guard let groupPendingDeletion else {
            return "This group will be permanently deleted."
        }

        return "\(groupPendingDeletion.name) will be permanently deleted."
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
