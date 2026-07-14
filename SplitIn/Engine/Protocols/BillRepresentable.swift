//
//  BillRepresentable.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import Foundation
protocol BillRepresentable {
    var paidByID: UUID {get}
    var adjustmentRate: Decimal {get}
    var itemsRepresentable: [BillItemRepresentable] {get}
}

