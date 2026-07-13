//
//  Settlement.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import Foundation
import SwiftData

@Model
final class Settlement {
    @Attribute(.unique)
    var id: UUID

    var amount: Decimal
    var status: SettlementStatus

    var group: Group
    var fromMember: GroupMember
    var toMember: GroupMember

    init(
        id: UUID = UUID(),
        group: Group,
        fromMember: GroupMember,
        toMember: GroupMember,
        amount: Decimal,
        status: SettlementStatus = .unpaid
    ) {
        precondition(
            fromMember.id != toMember.id,
            "Pengirim dan penerima settlement tidak boleh sama."
        )

        precondition(
            fromMember.groupID == group.id &&
            toMember.groupID == group.id,
            "Kedua anggota settlement harus berasal dari grup yang sama."
        )

        self.id = id
        self.group = group
        self.fromMember = fromMember
        self.toMember = toMember
        self.amount = amount
        self.status = status
    }
}
