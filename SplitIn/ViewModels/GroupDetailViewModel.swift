//
//  GroupDetailViewModel.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 16/07/26.
//

import Foundation
import Combine
import SwiftData

class GroupDetailViewModel: ObservableObject {
    let group: Group

    @Published var selectedMemberID: UUID?
    @Published var showDeleteAlert = false
    @Published var billPendingDelete: Bill?

    init(group: Group) {
        self.group = group
        self.selectedMemberID = group.members.first?.id
    }

    // MARK: - Computed

    var selectedMemberBalance: MemberBalance? {
        guard let id = selectedMemberID else { return nil }
        return group.balanceSheet()[id]
    }

    var sortedBills: [Bill] {
        group.bills.sorted {
            ($0.billDate ?? .distantPast) > ($1.billDate ?? .distantPast)
        }
    }

    // MARK: - Actions

    func selectMember(_ memberID: UUID) {
        selectedMemberID = memberID
    }

    func requestDelete(bill: Bill) {
        billPendingDelete = bill
        showDeleteAlert = true
    }

    func confirmDelete(using context: ModelContext) {
        guard let bill = billPendingDelete else { return }
        delete(bill: bill, using: context)
        billPendingDelete = nil
        showDeleteAlert = false
    }

    func delete(bill: Bill, using context: ModelContext) {
        group.bills.removeAll { $0.id == bill.id }
        context.delete(bill)
    }

    // MARK: - Formatting

    func memberName(for memberID: UUID) -> String {
        group.members.first(where: { $0.id == memberID })?.person.name.capitalized ?? "Unknown"
    }

    func formattedRupiah(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "Rp \(formatted)"
    }

    func billDisplayTotal(_ bill: Bill) -> String {
        let total: Decimal
        if let finalTotal = bill.totalFinal {
            total = finalTotal
        } else {
            total = bill.items.reduce(Decimal(0)) { $0 + $1.totalPrice }
        }
        let doubleVal = NSDecimalNumber(decimal: total).doubleValue
        if doubleVal >= 1000 {
            return "\(Int(doubleVal / 1000))k"
        }
        return "Rp \(Int(doubleVal))"
    }

    func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "–" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: date)
    }
}
