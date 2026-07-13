//
//  ItemSplit.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import Foundation
import SwiftData

@Model
final class ItemSplit {
    @Attribute(.unique)
    var id: UUID

    var shares: Decimal

    var item: BillItem
    var member: GroupMember

    init(
        id: UUID = UUID(),
        item: BillItem,
        member: GroupMember,
        shares: Decimal = 1
    ) {
        precondition(
            member.groupID == item.bill.group.id,
            "Anggota pembagian item harus berasal dari grup tagihan."
        )

        self.id = id
        self.item = item
        self.member = member
        self.shares = shares
    }
}
