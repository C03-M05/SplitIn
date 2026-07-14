//
//  MemberPair.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import Foundation

/// A normalized, order-independent key for two GroupMembers. `MemberPair(x, y)`
/// and `MemberPair(y, x)` always produce the same key, so debts between the
/// same two people accumulate into a single dictionary entry regardless of
/// who paid which bill.
struct MemberPair: Hashable {
    let a: UUID
    let b: UUID

    init(_ x: UUID, _ y: UUID) {
        if x.uuidString < y.uuidString {
            a = x
            b = y
        } else {
            a = y
            b = x
        }
    }
}
