//
//  SplitInTests.swift
//  SplitInTests
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import Testing
import SwiftData
@testable import SplitIn

@MainActor
struct SplitInTests {

    @Test func groupNameMustNotBeEmpty() {
        let viewModel = AddGroupViewModel()

        viewModel.groupNameDraft = "   "
        viewModel.commitGroupName()

        #expect(viewModel.groupName.isEmpty)
        #expect(viewModel.activeDialog == nil)
        #expect(viewModel.canSave == false)
    }

    @Test func groupNameIsTrimmedWhenCommitted() {
        let viewModel = AddGroupViewModel()

        viewModel.groupNameDraft = "  Trip Bandung  "
        viewModel.commitGroupName()

        #expect(viewModel.groupName == "Trip Bandung")
        #expect(viewModel.groupNameDraft.isEmpty)
        #expect(viewModel.activeDialog == nil)
    }

    @Test func memberNameMustNotBeEmpty() {
        let viewModel = AddGroupViewModel()

        viewModel.memberNameDraft = "\n  "
        viewModel.commitMemberName()

        #expect(viewModel.members.isEmpty)
        #expect(viewModel.canCommitMemberName == false)
    }

    @Test func memberNameIsTrimmedWhenCommitted() throws {
        let viewModel = AddGroupViewModel()

        viewModel.memberNameDraft = "  Ahmad  "
        viewModel.commitMemberName()

        let member = try #require(viewModel.members.first)
        #expect(member.name == "Ahmad")
        #expect(viewModel.memberNameDraft.isEmpty)
        #expect(viewModel.activeDialog == nil)
    }

    @Test func duplicateMemberNameIsRejectedIgnoringCaseAndDiacritics() {
        let viewModel = AddGroupViewModel()

        viewModel.memberNameDraft = "Éka"
        viewModel.commitMemberName()
        viewModel.memberNameDraft = "eka"
        viewModel.commitMemberName()

        #expect(viewModel.members.map(\.name) == ["Éka"])
        #expect(viewModel.memberNameAlreadyExists == true)
        #expect(viewModel.canCommitMemberName == false)
    }

    @Test func groupRequiresNameAndAtLeastTwoMembersBeforeSaving() {
        let viewModel = AddGroupViewModel()

        viewModel.groupName = "Kontrakan"
        viewModel.members = [
            DraftGroupMember(name: "Ahmad")
        ]

        #expect(viewModel.canSave == false)
    }

    @Test func savingInvalidGroupShowsSaveErrorAndDoesNotInsertGroup() throws {
        let context = try makeInMemoryModelContext()
        let viewModel = AddGroupViewModel()

        let didSave = viewModel.save(in: context)
        let groups = try context.fetch(FetchDescriptor<Group>())

        #expect(didSave == false)
        #expect(groups.isEmpty)
        #expect(viewModel.activeDialog == .saveError)
        #expect(viewModel.saveErrorMessage == "A group name and at least two members are required.")
    }

    @Test func savingValidGroupPersistsGroupAndMembersThenResetsForm() throws {
        let context = try makeInMemoryModelContext()
        let viewModel = AddGroupViewModel()

        viewModel.groupName = "Dinner"
        viewModel.members = [
            DraftGroupMember(name: "Ahmad"),
            DraftGroupMember(name: "Budi")
        ]

        let didSave = viewModel.save(in: context)
        let groups = try context.fetch(FetchDescriptor<Group>())
        let people = try context.fetch(FetchDescriptor<Person>())
        let groupMembers = try context.fetch(FetchDescriptor<GroupMember>())

        #expect(didSave == true)
        #expect(groups.map(\.name) == ["Dinner"])
        #expect(people.map(\.name).sorted() == ["Ahmad", "Budi"])
        #expect(groupMembers.count == 2)
        #expect(viewModel.groupName.isEmpty)
        #expect(viewModel.members.isEmpty)
        #expect(viewModel.activeDialog == nil)
    }

    @Test func memberCanBeRemovedBeforeBeingUsedInBill() {
        let viewModel = AddGroupViewModel()
        let member = DraftGroupMember(name: "Ahmad")

        viewModel.members = [
            member,
            DraftGroupMember(name: "Budi")
        ]
        viewModel.removeMember(id: member.id)

        #expect(viewModel.members.map(\.name) == ["Budi"])
    }

    private func makeInMemoryModelContext() throws -> ModelContext {
        let schema = Schema([
            Group.self,
            Person.self,
            GroupMember.self,
            Bill.self,
            BillItem.self,
            ItemSplit.self,
            Settlement.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        return ModelContext(container)
    }
}
