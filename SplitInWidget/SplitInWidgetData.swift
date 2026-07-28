//
//  SplitInWidgetData.swift
//  SplitInWidget
//

import Foundation

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

    static let empty = SplitInWidgetSnapshot(updatedAt: Date(), groups: [])

    var defaultGroup: SplitInWidgetGroupSnapshot? {
        groups.first
    }

    func group(with id: UUID?) -> SplitInWidgetGroupSnapshot? {
        guard let id else { return defaultGroup }
        return groups.first { $0.id == id } ?? defaultGroup
    }
}

enum SplitInWidgetFormatter {
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
    static let appGroupIdentifier = "group.com.ahmadfarhanqf.SplitIn"
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

    static func selectedGroupID(from rawValue: String?) -> UUID? {
        guard let rawValue, rawValue != "placeholder" else {
            return nil
        }
        return UUID(uuidString: rawValue)
    }

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }
}
