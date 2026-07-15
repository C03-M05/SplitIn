//
//  DebtCalculationEngineTests.swift
//  SplitInTests
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import XCTest
@testable import SplitIn

private struct MockSplit: SplitRepresentable {
    var memberID: UUID
    var shares: Decimal
}

private struct MockBillItem: BillItemRepresentable {
    var totalPrice: Decimal
    var splitsRepresentable: [SplitRepresentable]
}

private struct MockBill: BillRepresentable {
    var paidByID: UUID
    var adjustmentRate: Decimal
    var itemsRepresentable: [BillItemRepresentable]
}

final class DebtCalculationEngineTests: XCTestCase {

    func test_equalShares_splitsEvenly() {
        let sherin = UUID(), axel = UUID(), farhan = UUID()

        let item = MockBillItem(
            totalPrice: 60_000,
            splitsRepresentable: [
                MockSplit(memberID: sherin, shares: 1),
                MockSplit(memberID: axel, shares: 1),
                MockSplit(memberID: farhan, shares: 1)
            ]
        )
        let bill = MockBill(paidByID: sherin, adjustmentRate: 0, itemsRepresentable: [item])

        let debts = DebtCalculationEngine.debts(for: bill)

        XCTAssertEqual(debts[axel], 20_000)
        XCTAssertEqual(debts[farhan], 20_000)
        XCTAssertNil(debts[sherin], "Payer should never owe themselves")
    }

    func test_weightedShares_splitsProportionally() {
        // Future-proofing check: A gets 2 shares, B gets 1 share of a 90.000 item.
        let a = UUID(), b = UUID(), payer = UUID()
        let item = MockBillItem(
            totalPrice: 90_000,
            splitsRepresentable: [
                MockSplit(memberID: a, shares: 2),
                MockSplit(memberID: b, shares: 1)
            ]
        )
        let bill = MockBill(paidByID: payer, adjustmentRate: 0, itemsRepresentable: [item])

        let debts = DebtCalculationEngine.debts(for: bill)

        XCTAssertEqual(debts[a], 60_000)
        XCTAssertEqual(debts[b], 30_000)
    }

    func test_netBalances_pairwiseNetting_matchesProductExample() {
        // "Aku diutangi 200rb tapi aku utang 100rb ke orang yg sama -> net 100rb"
        let me = UUID(), x = UUID()

        let billIOwe = MockBill(
            paidByID: x,
            adjustmentRate: 0,
            itemsRepresentable: [MockBillItem(
                totalPrice: 200_000,
                splitsRepresentable: [MockSplit(memberID: me, shares: 1), MockSplit(memberID: x, shares: 1)]
            )]
        )
        let billTheyOwe = MockBill(
            paidByID: me,
            adjustmentRate: 0,
            itemsRepresentable: [MockBillItem(
                totalPrice: 200_000,
                splitsRepresentable: [MockSplit(memberID: me, shares: 1), MockSplit(memberID: x, shares: 1)]
            )]
        )

        let net = DebtCalculationEngine.netBalances(bills: [billIOwe, billTheyOwe])

        XCTAssertTrue(net.isEmpty, "Equal opposite debts should fully cancel out")
    }

    func test_adjustmentRate_discountAppliesProportionally() {
        let sherin = UUID(), axel = UUID()
        let item = MockBillItem(
            totalPrice: 100_000,
            splitsRepresentable: [MockSplit(memberID: sherin, shares: 1), MockSplit(memberID: axel, shares: 1)]
        )
        // -10% adjustment
        let bill = MockBill(paidByID: sherin, adjustmentRate: -0.1, itemsRepresentable: [item])

        let debts = DebtCalculationEngine.debts(for: bill)

        XCTAssertEqual(debts[axel], 45_000, "50.000 raw share * 0.9 discount = 45.000")
    }

    func test_editingOrDeletingABill_recomputesFromScratch_noStateDrift() {
        let sherin = UUID(), axel = UUID()
        let bill = MockBill(
            paidByID: sherin,
            adjustmentRate: 0,
            itemsRepresentable: [MockBillItem(
                totalPrice: 40_000,
                splitsRepresentable: [MockSplit(memberID: sherin, shares: 1), MockSplit(memberID: axel, shares: 1)]
            )]
        )

        XCTAssertFalse(DebtCalculationEngine.netBalances(bills: [bill]).isEmpty)
        XCTAssertTrue(DebtCalculationEngine.netBalances(bills: []).isEmpty)
    }
}
