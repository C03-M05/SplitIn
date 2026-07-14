//
//  ModelAdapters.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//
//  Bridges the real SwiftData models (Models/Bill.swift, BillItem.swift,
//  ItemSplit.swift) to the Engine's protocols. This file is the ONLY place
//  that connects persistence to calculation logic — nothing in Models/ is
//  modified, and DebtCalculationEngine.swift never imports SwiftData.
//

import Foundation

extension ItemSplit: SplitRepresentable {
    var memberID: UUID { member.id }
}

extension BillItem: BillItemRepresentable {
    var splitsRepresentable: [SplitRepresentable] {
        splits.map { $0 as SplitRepresentable }
    }
}

extension Bill: BillRepresentable {
    var paidByID: UUID { paidBy.id }

    var itemsRepresentable: [BillItemRepresentable] {
        items.map { $0 as BillItemRepresentable }
    }

    var adjustmentRate: Decimal {
        guard let finalTotal = totalFinal else { return 0 }
        let computedSubtotal = items.reduce(Decimal(0)) { $0 + $1.totalPrice }
        guard computedSubtotal > 0 else { return 0 }
        return (finalTotal - computedSubtotal) / computedSubtotal
    }
}
