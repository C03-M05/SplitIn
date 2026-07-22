//
//  BalanceSheet.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import Foundation

/// One line in a "Pay to" or "Collect from" list — e.g. "Rp 30.000 -> Miranda".
struct BalanceEntry: Identifiable, Hashable {
    let id = UUID()
    /// The `GroupMember.id` on the other side of this entry.
    let counterpartyMemberID: UUID
    let amount: Decimal
}

/// Full balance breakdown for one GroupMember — this is exactly the shape
/// the "Pay to" / "Collect from" cards need.
struct MemberBalance: Identifiable {
    let id: UUID   // == GroupMember.id
    let payTo: [BalanceEntry]
    let collectFrom: [BalanceEntry]
}

/// Balance breakdown for every member of a group, keyed by GroupMember.id.
struct BalanceSheet {
    let balances: [UUID: MemberBalance]

    subscript(memberID: UUID) -> MemberBalance? { balances[memberID] }
}
