//
//  GroupMember.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import Foundation
import SwiftData

@Model
final class GroupMember {
    /*
     Menggantikan:

     UNIQUE(group_id, person_id)

     groupID dan personID disimpan sebagai scalar agar dapat
     digunakan sebagai compound unique constraint.
     */
    #Unique<GroupMember>([
        \.groupID,
        \.personID
    ])

    @Attribute(.unique)
    var id: UUID

    private(set) var groupID: UUID
    private(set) var personID: UUID

    var group: Group
    var person: Person

    /*
     Anggota tidak boleh dihapus selama masih tercatat
     sebagai pembayar suatu tagihan.
     */
    @Relationship(
        deleteRule: .deny,
        inverse: \Bill.paidBy
    )
    var paidBills: [Bill] = []

    @Relationship(
        deleteRule: .cascade,
        inverse: \ItemSplit.member
    )
    var itemSplits: [ItemSplit] = []

    @Relationship(
        deleteRule: .deny,
        inverse: \Settlement.fromMember
    )
    var outgoingSettlements: [Settlement] = []

    @Relationship(
        deleteRule: .deny,
        inverse: \Settlement.toMember
    )
    var incomingSettlements: [Settlement] = []

    init(
        id: UUID = UUID(),
        group: Group,
        person: Person
    ) {
        self.id = id
        self.groupID = group.id
        self.personID = person.id
        self.group = group
        self.person = person
    }
}
