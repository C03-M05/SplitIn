//
//  SplitInWidgetData.swift
//  SplitIn
//

import Foundation
import WidgetKit

struct SplitInWidgetBillSnapshot: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let amount: Decimal
    let displayAmount: String
    let billDate: Date?
}

struct SplitInWidgetGroupSnapshot: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let bills: [SplitInWidgetBillSnapshot]
    let checklistText: String

    var totalDisplayAmount: String {
        SplitInWidgetFormatter.shortRupiah(
            bills.reduce(Decimal(0)) { $0 + $1.amount }
        )
    }
}

struct SplitInWidgetSnapshot: Codable, Hashable {
    let updatedAt: Date
    let groups: [SplitInWidgetGroupSnapshot]

    static let empty = SplitInWidgetSnapshot(updatedAt: .now, groups: [])

    var defaultGroup: SplitInWidgetGroupSnapshot? {
        groups.first
    }

    func group(with id: UUID?) -> SplitInWidgetGroupSnapshot? {
        guard let id else { return defaultGroup }
        return groups.first { $0.id == id } ?? defaultGroup
    }
}

enum SplitInWidgetFormatter {
    static func rupiah(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formattedNumber = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "Rp \(formattedNumber)"
    }

    static func shortRupiah(_ amount: Decimal) -> String {
        let value = NSDecimalNumber(decimal: amount).doubleValue
        if value >= 1_000_000 {
            return "Rp \(Int(value / 1_000_000))jt"
        }
        if value >= 1_000 {
            return "Rp \(Int(value / 1_000))k"
        }
        return "Rp \(Int(value))"
    }
}

enum SplitInWidgetStore {
    static let appGroupIdentifier = "group.com.farhan.SplitIn"
    static let widgetKind = "SplitInWidget"

    private static let snapshotKey = "splitIn.widget.snapshot"

    static func loadSnapshot() -> SplitInWidgetSnapshot {
        guard let data = defaults.data(forKey: snapshotKey) else {
            return .empty
        }

        do {
            return try JSONDecoder().decode(SplitInWidgetSnapshot.self, from: data)
        } catch {
            return .empty
        }
    }

    @MainActor
    static func save(groups: [Group]) {
        save(
            SplitInWidgetSnapshot(
                updatedAt: .now,
                groups: groups
                    .sorted { lhs, rhs in lhs.createdAt > rhs.createdAt }
                    .map(Self.snapshot(for:))
            )
        )
    }

    static func save(group: Group) {
        var groups = loadSnapshot().groups.filter { $0.id != group.id }
        groups.append(snapshot(for: group))
        groups.sort { lhs, rhs in
            (lhs.bills.first?.billDate ?? .distantPast) > (rhs.bills.first?.billDate ?? .distantPast)
        }
        save(SplitInWidgetSnapshot(updatedAt: .now, groups: groups))
    }

    private static func save(_ snapshot: SplitInWidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        defaults.set(data, forKey: snapshotKey)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }

    static func selectedGroupID(from rawValue: String?) -> UUID? {
        guard let rawValue, rawValue != "placeholder" else {
            return nil
        }
        return UUID(uuidString: rawValue)
    }

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    private static func snapshot(for group: Group) -> SplitInWidgetGroupSnapshot {
        let bills = group.bills
            .sorted { ($0.billDate ?? .distantPast) > ($1.billDate ?? .distantPast) }
            .map { bill in
                let amount = bill.totalFinal ?? bill.items.reduce(Decimal(0)) { $0 + $1.totalPrice }
                return SplitInWidgetBillSnapshot(
                    id: bill.id,
                    name: bill.name,
                    amount: amount,
                    displayAmount: SplitInWidgetFormatter.shortRupiah(amount),
                    billDate: bill.billDate
                )
            }

        return SplitInWidgetGroupSnapshot(
            id: group.id,
            name: group.name,
            bills: bills,
            checklistText: RepaymentChecklistViewModel.checklistText(for: group)
        )
    }
}
