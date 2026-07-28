//
//  SplitInWidgetEntry.swift
//  SplitInWidget
//

import Foundation
import WidgetKit

struct SplitInWidgetEntry: TimelineEntry {
    let date: Date
    let group: SplitInWidgetGroupSnapshot?

    static func preview() -> SplitInWidgetEntry {
        SplitInWidgetEntry(
            date: .now,
            group: SplitInWidgetGroupSnapshot(
                id: UUID(),
                name: "Malang Trip",
                bills: [
                    SplitInWidgetBillSnapshot(
                        id: UUID(),
                        name: "Grab",
                        amount: 65_000,
                        displayAmount: "Rp 65k",
                        billDate: .now
                    ),
                    SplitInWidgetBillSnapshot(
                        id: UUID(),
                        name: "Ayam Goreng",
                        amount: 54_000,
                        displayAmount: "Rp 54k",
                        billDate: .now
                    ),
                    SplitInWidgetBillSnapshot(
                        id: UUID(),
                        name: "Es Teh",
                        amount: 35_000,
                        displayAmount: "Rp 35k",
                        billDate: .now
                    )
                ],
                checklistText: "*[Malang Trip]*"
            )
        )
    }
}
