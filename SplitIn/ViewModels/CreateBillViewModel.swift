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
    
    // Logika Mengatur penambahan dan pengurangan baris item menu makanan secara dinamis di layar.
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
    
    // Logika Kalkulasi total items
    var totalBillAmount: Int {
        formItems.reduce(0) { result, item in
            result + (item.price * item.quantity)
        }
    }
    
    // Logika Validasi Form
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
    
    // LOGIKA PROBABILITAS PEMBAGIAN OTOMATIS BERDASARKAN MODEL SHARES
    func saveBill(modelContext: ModelContext) {
        guard isFormValid, let payer = selectedPayer else { return }
        
        // Menentukan total akhir
        let finalAmount = rawGrandTotal > 0 ? rawGrandTotal : totalBillAmount
        
        let newBill = Bill(
            group: currentGroup,
            paidBy: payer,
            name: billName,
            billDate: billDate,
            subTotal: Decimal(totalBillAmount),
            totalFinal: Decimal(finalAmount)
        )
        
        modelContext.insert(newBill)
        
        for formItem in formItems {
            let newBillItem = BillItem(
                bill: newBill,
                name: formItem.name,
                price: Decimal(formItem.price),
                quantity: Decimal(formItem.quantity)
            )
            modelContext.insert(newBillItem)
            for memberID in formItem.assignedMemberIDs {
                if let matchedMember = currentGroup.members.first(where: { $0.id == memberID }) {
                    // Berikan nilai jatah jualan shares = 1 per konsumen
                    let newSplit = ItemSplit(
                        item: newBillItem,
                        member: matchedMember,
                        shares: 1 
                    )
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

// MARK: - Kelas FormItemInput @Observable Tetap Dipertahankan Utuh
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
