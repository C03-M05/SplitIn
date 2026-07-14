//
//  BillItemRepresentable.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import Foundation

protocol BillItemRepresentable {
    var totalPrice: Decimal { get }
    var splitsRepresentable: [SplitRepresentable] { get }
}
