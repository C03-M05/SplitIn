//
//  BillItem.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import Foundation
import SwiftData

@Model
final class BillItem {
    @Attribute(.unique)
    var id: UUID

    var name: String
    var price: Decimal
    var quantity: Decimal

    var bill: Bill

    @Relationship(
        deleteRule: .cascade,
        inverse: \ItemSplit.item
    )
    var splits: [ItemSplit] = []

    init(
        id: UUID = UUID(),
        bill: Bill,
        name: String,
        price: Decimal,
        quantity: Decimal = 1
    ) {
        self.id = id
        self.bill = bill
        self.name = name
        self.price = price
        self.quantity = quantity
    }

    var totalPrice: Decimal {
        price * quantity
    }
}
