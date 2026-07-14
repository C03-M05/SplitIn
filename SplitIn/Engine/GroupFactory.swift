//
//  GroupFactory.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//
//  Centralizes how a valid Group + GroupMember graph gets constructed.
//  ViewModels call this instead of
//  building Person/GroupMember relationships by hand — keeps the
//  invariants (compound unique constraint, cascade rules) in one place.
//

import Foundation
import SwiftData

enum GroupFactory {

    @discardableResult
    static func createGroup(context: ModelContext, name: String, memberNames: [String]) -> Group {
        let group = Group(name: name)
        context.insert(group)

        for memberName in memberNames {
            _ = addMember(context: context, to: group, name: memberName)
        }
        return group
    }

    @discardableResult
    static func addMember(context: ModelContext, to group: Group, name: String) -> GroupMember {
        let person = Person(name: name)
        context.insert(person)

        let member = GroupMember(group: group, person: person)
        context.insert(member)
        group.members.append(member)

        return member
    }

    /// Throws if the member has paid any bills — SwiftData's `.deny` delete
    /// rule on `paidBills` will refuse the save, so we check up front and
    /// surface a clean error instead of a raw SwiftData save failure.
    static func removeMember(_ member: GroupMember, from group: Group, context: ModelContext) throws {
        guard member.paidBills.isEmpty else {
            throw GroupFactoryError.memberHasPaidBills(member.id)
        }
        group.members.removeAll { $0.id == member.id }
        context.delete(member)
    }

    static func renameGroup(_ group: Group, to newName: String) {
        group.name = newName
    }
}

enum GroupFactoryError: Error, LocalizedError {
    case memberHasPaidBills(UUID)

    var errorDescription: String? {
        switch self {
        case .memberHasPaidBills:
            return "Anggota ini gak bisa dihapus karena masih tercatat sebagai pembayar di salah satu bill."
        }
    }
}
