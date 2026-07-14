//
//  Group+Balance.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//  Convenience so ViewModels don't have to manually map `group.bills` /
//  `group.members` into the Engine's protocol types every time.
//
//  Usage from a ViewModel:
//      let sheet = group.balanceSheet()
//      let myBalance = sheet[someGroupMember.id]
//

import Foundation

extension Group {
    func balanceSheet() -> BalanceSheet {
        DebtCalculationEngine.balanceSheet(
            bills: bills.map { $0 as BillRepresentable },
            memberIDs: members.map(\.id)
        )
    }
}
