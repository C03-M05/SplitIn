//
//  CreateBillViewModel.swift
//  SplitIn
//
//  Created by Miranda Utami on 15/07/26.
//

import Foundation
import SwiftData
import Observation

@Observable
class CreateBillViewModel {
    // MARK: - Properties Form
    var billName: String = ""
    var billDate: Date = Date()
    var selectedPayer: GroupMember?
    let currentGroup: Group
    var isEditMode: Bool = false
    private var editingBill: Bill?

    // Array penampung baris form
    var formItems: [FormItemInput] = [FormItemInput()]

    private var rawGrandTotal: Int = 0
    var manualGrandTotal: String {
        get { rawGrandTotal == 0 ? "" : formatNumberString("\(rawGrandTotal)") }
        set {
            let cleanDigits = newValue.filter { $0.isNumber }
            rawGrandTotal = Int(cleanDigits) ?? 0
        }
    }

    init(group: Group) {
        self.currentGroup = group
    }

    init(bill: Bill) {
        self.currentGroup = bill.group
        self.editingBill = bill
        self.isEditMode = true
        self.billName = bill.name
        self.billDate = bill.billDate ?? Date()
        self.selectedPayer = bill.paidBy
        if let total = bill.totalFinal {
            self.rawGrandTotal = NSDecimalNumber(decimal: total).intValue
        }
        let items = bill.items
        self.formItems = items.isEmpty
            ? [FormItemInput()]
            : items.enumerated().map { FormItemInput(from: $0.element, displayIndex: $0.offset + 1) }
    }
    
    func addItem() {
        let nextIndex = formItems.count + 1
        formItems.append(FormItemInput(displayIndex: nextIndex))
    }
    
    func removeItem(id: UUID) {
        guard formItems.count > 1 else { return }
        formItems.removeAll(where: { $0.id == id })
        for i in 0..<formItems.count {
            formItems[i].displayIndex = i + 1
        }
    }
    
    var totalBillAmount: Int {
        formItems.reduce(0) { result, item in
            result + (item.price * item.quantity)
        }
    }
    
    //GrandTotal
    var isFormValid: Bool {
        let isNameFilled = !billName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isPayerSelected = selectedPayer != nil
        
        let areItemsValid = !formItems.isEmpty && formItems.allSatisfy { item in
            let hasName = !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasPrice = item.price > 0
            let hasQuantity = item.quantity > 0
            let hasMembers = !item.assignedMemberIDs.isEmpty
            return hasName && hasPrice && hasQuantity && hasMembers
        }
        
        return isNameFilled && isPayerSelected && areItemsValid
    }
    
    func saveBill(modelContext: ModelContext) {
        guard isFormValid, let payer = selectedPayer else { return }

        let finalAmount = rawGrandTotal > 0 ? rawGrandTotal : totalBillAmount
        let targetBill: Bill

        if let existing = editingBill {
            existing.name = billName
            existing.paidBy = payer
            existing.billDate = billDate
            existing.subTotal = Decimal(totalBillAmount)
            existing.totalFinal = Decimal(finalAmount)
            for oldItem in existing.items { modelContext.delete(oldItem) }
            existing.items.removeAll()
            targetBill = existing
        } else {
            let newBill = Bill(
                group: currentGroup,
                paidBy: payer,
                name: billName,
                billDate: billDate,
                subTotal: Decimal(totalBillAmount),
                totalFinal: Decimal(finalAmount)
            )
            modelContext.insert(newBill)
            targetBill = newBill
        }

        for formItem in formItems {
            let newBillItem = BillItem(
                bill: targetBill,
                name: formItem.name,
                price: Decimal(formItem.price),
                quantity: Decimal(formItem.quantity)
            )
            modelContext.insert(newBillItem)
            for memberID in formItem.assignedMemberIDs {
                if let matchedMember = currentGroup.members.first(where: { $0.id == memberID }) {
                    let newSplit = ItemSplit(item: newBillItem, member: matchedMember)
                    modelContext.insert(newSplit)
                }
            }
        }
        try? modelContext.save()
    }
    
    
    
    func formatToRupiah(_ value: Int) -> String {
        return "Rp " + formatNumberString("\(value)")
    }
    
    private func formatNumberString(_ string: String) -> String {
        let clean = string.filter { $0.isNumber }
        guard let number = Int(clean) else { return "" }
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}

// MARK: - Diubah Menjadi Kelas @Observable
@Observable
class FormItemInput: Identifiable, Equatable {
    let id = UUID()
    var name: String = ""
    var price: Int = 0
    var quantity: Int = 1
    var assignedMemberIDs: Set<UUID> = []
    var displayIndex: Int = 1
    
    init(displayIndex: Int = 1) {
        self.displayIndex = displayIndex
    }

    init(from billItem: BillItem, displayIndex: Int) {
        self.displayIndex = displayIndex
        self.name = billItem.name
        self.price = NSDecimalNumber(decimal: billItem.price).intValue
        self.quantity = NSDecimalNumber(decimal: billItem.quantity).intValue
        self.assignedMemberIDs = Set(billItem.splits.map { $0.member.id })
    }
    
    var priceBindingString: String {
        get { price == 0 ? "" : formatNumberString("\(price)") }
        set {
            let cleanDigits = newValue.filter { $0.isNumber }
            price = Int(cleanDigits) ?? 0
        }
    }
    
    private func formatNumberString(_ string: String) -> String {
        let clean = string.filter { $0.isNumber }
        guard let number = Int(clean) else { return "" }
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
    
    static func == (lhs: FormItemInput, rhs: FormItemInput) -> Bool {
        lhs.id == rhs.id
    }
}
