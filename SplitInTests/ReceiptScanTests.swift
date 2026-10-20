
import Foundation
import Testing
@testable import SplitIn

@MainActor
struct ReceiptScanTests {
    @Test func applyingReceiptUsesUnitPricesAndClearsAssignments() {
        let model = CreateBillViewModel(group: Group(name: "Trip"))
        model.formItems[0].assignedMemberIDs = [UUID()]
        let receipt = ScannedReceipt(merchant: " Cafe ", date: "2026-10-20", currency: "IDR",
                                     total: 55000, items: [
                                        ScannedReceiptItem(name: "Coffee", quantity: 2, unitPrice: 25000)
                                     ])
        model.applyScannedReceipt(receipt)
        #expect(model.billName == "Cafe")
        #expect(model.totalBillAmount == 50000)
        #expect(model.manualGrandTotal == "55.000")
        #expect(model.formItems[0].assignedMemberIDs.isEmpty)
        #expect(model.selectedPayer == nil)
        #expect(!model.isFormValid)
    }

    @Test func uncertainAndOutOfRangeNumbersRemainInvalid() {
        let model = CreateBillViewModel(group: Group(name: "Trip"))
        model.applyScannedReceipt(ScannedReceipt(merchant: nil, date: nil, currency: nil,
                                                total: Int.max, items: [
                                                    ScannedReceiptItem(name: "Item", quantity: Int.max, unitPrice: -10),
                                                    ScannedReceiptItem(name: "Unknown", quantity: nil, unitPrice: nil)
                                                ]))
        #expect(model.billName.isEmpty)
        #expect(model.manualGrandTotal.isEmpty)
        #expect(model.totalBillAmount == 0)
        #expect(model.formItems.allSatisfy { $0.quantity == 0 && $0.price == 0 })
        #expect(!model.isFormValid)
    }

    @Test func invalidDateDoesNotReplaceExistingDate() {
        let model = CreateBillViewModel(group: Group(name: "Trip"))
        let originalDate = model.billDate
        model.applyScannedReceipt(ScannedReceipt(merchant: "Cafe", date: "2026-02-31", currency: nil,
                                                total: nil, items: []))
        #expect(model.billDate == originalDate)
        #expect(model.formItems.count == 1)
        #expect(!model.isFormValid)
    }
}
