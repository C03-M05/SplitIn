//
//  AddGroupViewModel.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 14/07/26.
//

import Foundation
import Observation
import SwiftData

struct DraftGroupMember: Identifiable, Equatable {
    let id: UUID
    var name: String
    var originalMemberID: UUID?

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.originalMemberID = nil
    }

    init(from groupMember: GroupMember) {
        self.id = UUID()
        self.name = groupMember.person.name
        self.originalMemberID = groupMember.id
    }

    var initial: String {
        guard let firstCharacter = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .first
        else {
            return "?"
        }

        return String(firstCharacter).uppercased()
    }
}

@MainActor
@Observable
final class AddGroupViewModel {
    static let minimumMemberCount = 2

    enum ActiveDialog {
        case groupName
        case memberName
        case saveError
    }

    var groupName: String = ""
    var groupNameDraft: String = ""
    var memberNameDraft: String = ""

    var members: [DraftGroupMember] = []

    var activeDialog: ActiveDialog?
    var saveErrorMessage: String = ""

    var isEditMode: Bool = false
    private var editingGroup: Group?

    var normalizedGroupName: String {
        Self.trimmed(groupName)
    }

    var normalizedGroupNameDraft: String {
        Self.trimmed(groupNameDraft)
    }

    var normalizedMemberNameDraft: String {
        Self.trimmed(memberNameDraft)
    }

    var canCommitGroupName: Bool {
        !normalizedGroupNameDraft.isEmpty
    }

    var memberNameAlreadyExists: Bool {
        guard !normalizedMemberNameDraft.isEmpty else {
            return false
        }

        return members.contains { member in
            member.name.compare(
                normalizedMemberNameDraft,
                options: [
                    .caseInsensitive,
                    .diacriticInsensitive
                ]
            ) == .orderedSame
        }
    }

    var canCommitMemberName: Bool {
        !normalizedMemberNameDraft.isEmpty &&
        !memberNameAlreadyExists
    }

    var canSave: Bool {
        !normalizedGroupName.isEmpty &&
        members.count >= Self.minimumMemberCount
    }

    var formStatusText: String {
        if normalizedGroupName.isEmpty && members.isEmpty {
            return "Add a group name and at least two members."
        }

        if normalizedGroupName.isEmpty {
            return "A group name is required."
        }

        if members.count < Self.minimumMemberCount {
            return "Add at least two group members."
        }

        return "The group is ready to save."
    }

    var dialogTitle: String {
        switch activeDialog {
        case .some(.groupName):
            return "Group Name"

        case .some(.memberName):
            return "Member Name"

        case .some(.saveError):
            return "Unable to Save Group"

        case .none:
            return ""
        }
    }

    var dialogMessage: String {
        switch activeDialog {
        case .some(.groupName):
            return "Enter a name for this group."

        case .some(.memberName):
            if memberNameAlreadyExists {
                return "This member is already in the group."
            }

            return "Enter the member's name."

        case .some(.saveError):
            return saveErrorMessage

        case .none:
            return ""
        }
    }

    func beginEditingGroupName() {
        groupNameDraft = groupName
        activeDialog = .groupName
    }

    func commitGroupName() {
        guard canCommitGroupName else {
            return
        }

        groupName = normalizedGroupNameDraft
        groupNameDraft = ""
        activeDialog = nil
    }

    func beginAddingMember() {
        memberNameDraft = ""
        activeDialog = .memberName
    }

    func commitMemberName() {
        guard canCommitMemberName else {
            return
        }

        let member = DraftGroupMember(
            name: normalizedMemberNameDraft
        )

        members.append(member)
        memberNameDraft = ""
        activeDialog = nil
    }

    func removeMember(id: UUID) {
        members.removeAll { member in member.id == id }
    }

    func dismissDialog() {
        switch activeDialog {
        case .some(.groupName):
            groupNameDraft = ""

        case .some(.memberName):
            memberNameDraft = ""

        case .some(.saveError), .none:
            break
        }

        activeDialog = nil
    }

    init() {}

    init(group: Group) {
        groupName = group.name
        members = group.members.map { DraftGroupMember(from: $0) }
        isEditMode = true
        editingGroup = group
    }

    @discardableResult
    func save(in modelContext: ModelContext) -> Bool {
        guard canSave else {
            presentSaveError(message: "A group name and at least two members are required.")
            return false
        }

        if let existing = editingGroup {
            GroupFactory.renameGroup(existing, to: normalizedGroupName)

            let keptIDs = Set(members.compactMap { $0.originalMemberID })
            let toRemove = existing.members.filter { !keptIDs.contains($0.id) }
            for member in toRemove {
                do {
                    try GroupFactory.removeMember(member, from: existing, context: modelContext)
                } catch {
                    modelContext.rollback()
                    presentSaveError(message: "\(member.person.name) can't be removed — they're linked to an existing bill.")
                    return false
                }
            }

            for draft in members where draft.originalMemberID == nil {
                GroupFactory.addMember(context: modelContext, to: existing, name: draft.name)
            }
        } else {
            GroupFactory.createGroup(
                context: modelContext,
                name: normalizedGroupName,
                memberNames: members.map(\.name)
            )
        }

        do {
            try modelContext.save()
            reset()
            return true
        } catch {
            modelContext.rollback()
            presentSaveError(message: error.localizedDescription)
            return false
        }
    }

    private func presentSaveError(message: String) {
        saveErrorMessage = message
        activeDialog = .saveError
    }

    private func reset() {
        groupName = ""
        groupNameDraft = ""
        memberNameDraft = ""
        members.removeAll()
        saveErrorMessage = ""
        activeDialog = nil
    }

    private static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
}
