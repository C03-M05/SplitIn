//
//  Bill.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import Foundation
import SwiftData

@Model
final class Bill {
    @Attribute(.unique)
    var id: UUID

    var name: String
    var billDate: Date?
    var subTotal: Decimal?
    var totalFinal: Decimal?

    var group: Group
    var paidBy: GroupMember

    @Relationship(
        deleteRule: .cascade,
        inverse: \BillItem.bill
    )
    var items: [BillItem] = []

    init(
        id: UUID = UUID(),
        group: Group,
        paidBy: GroupMember,
        name: String,
        billDate: Date? = nil,
        subTotal: Decimal? = nil,
        totalFinal: Decimal? = nil
    ) {
        precondition(
            paidBy.groupID == group.id,
            "Pembayar harus merupakan anggota dari grup tagihan."
        )

        self.id = id
        self.group = group
        self.paidBy = paidBy
        self.name = name
        self.billDate = billDate
        self.subTotal = subTotal
        self.totalFinal = totalFinal
    }
}
