//
//  BillFactory.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//
//  Centralizes how a valid Bill + BillItem + ItemSplit graph gets built.
//  Dev B's CreateEditBillViewModel (create) AND the edit flow BOTH call
//  this — writing the wiring logic in two ViewModels independently is
//  exactly the kind of duplication CLAUDE.md warns against.
//

import Foundation
import SwiftData

/// Plain-data draft for one item, built by the Create/Edit Bill form.
/// `participantMemberIDs` all get `shares = 1` for MVP (equal split) —
/// see ItemSplit.shares doc comment for why this isn't a stored amount.
struct BillItemDraft {
    var name: String
    var price: Decimal
    var quantity: Decimal
    var participantMemberIDs: [UUID]
}

enum BillFactory {

    @discardableResult
    static func createBill(
        context: ModelContext,
        group: Group,
        paidBy: GroupMember,
        name: String,
        billDate: Date? = nil,
        items: [BillItemDraft],
        totalFinal: Decimal? = nil
    ) throws -> Bill {
        let bill = Bill(group: group, paidBy: paidBy, name: name, billDate: billDate)
        context.insert(bill)

        let subtotal = try attachItems(items, to: bill, group: group, context: context)

        bill.subTotal = subtotal
        bill.totalFinal = totalFinal
        group.bills.append(bill)

        return bill
    }

    static func updateBill(
        context: ModelContext,
        bill: Bill,
        name: String,
        paidBy: GroupMember,
        billDate: Date?,
        items: [BillItemDraft],
        totalFinal: Decimal?
    ) throws {
        bill.name = name
        bill.paidBy = paidBy
        bill.billDate = billDate

        // Replace items wholesale — simplest correct approach for MVP scope.
        for oldItem in bill.items {
            for split in oldItem.splits {
                context.delete(split)
            }
            context.delete(oldItem)
        }
        bill.items.removeAll()

        let subtotal = try attachItems(items, to: bill, group: bill.group, context: context)

        bill.subTotal = subtotal
        bill.totalFinal = totalFinal
    }

    static func deleteBill(context: ModelContext, bill: Bill, from group: Group) {
        group.bills.removeAll { $0.id == bill.id }
        context.delete(bill)
    }

    // MARK: - Shared helper

    @discardableResult
    private static func attachItems(
        _ drafts: [BillItemDraft],
        to bill: Bill,
        group: Group,
        context: ModelContext
    ) throws -> Decimal {
        var subtotal: Decimal = 0

        for draft in drafts {
            let item = BillItem(bill: bill, name: draft.name, price: draft.price, quantity: draft.quantity)
            context.insert(item)

            for memberID in draft.participantMemberIDs {
                guard let member = group.members.first(where: { $0.id == memberID }) else {
                    throw BillFactoryError.memberNotFound(memberID)
                }
                let split = ItemSplit(item: item, member: member)
                context.insert(split)
                item.splits.append(split)
            }

            bill.items.append(item)
            subtotal += item.totalPrice
        }

        return subtotal
    }
}

enum BillFactoryError: Error, LocalizedError {
    case memberNotFound(UUID)

    var errorDescription: String? {
        switch self {
        case .memberNotFound(let id):
            return "Anggota dengan id \(id) gak ditemukan di grup ini."
        }
    }
}
