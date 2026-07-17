//
//  GroupSplitPDFView.swift
//  SplitIn
//
//  Rendered to PDF via ImageRenderer — NOT shown in-app directly.
//

import SwiftUI
import SwiftData

struct GroupSplitPDFView: View {
    let group: Group

    private var balanceSheet: BalanceSheet { group.balanceSheet() }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(group.members) { member in
                if let balance = balanceSheet[member.id] {
                    MemberPDFCard(
                        groupName: group.name,
                        memberName: member.person.name.capitalized,
                        balance: balance,
                        nameFor: { id in
                            group.members.first { $0.id == id }?.person.name.capitalized ?? "Unknown"
                        }
                    )
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
    }
}

// MARK: - Per-member card

private struct MemberPDFCard: View {
    let groupName: String
    let memberName: String
    let balance: MemberBalance
    let nameFor: (UUID) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(groupName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(red: 0.82, green: 0.37, blue: 0.22))
                Spacer()
                Text(memberName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }

            // Pay to
            SectionBox(title: "Pay to") {
                if balance.payTo.isEmpty {
                    Text("All settled up")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.gray)
                } else {
                    ForEach(balance.payTo) { entry in
                        HStack(spacing: 0) {
                            Text(formatRupiah(entry.amount))
                                .frame(width: 110, alignment: .leading)
                            Text("→")
                                .padding(.horizontal, 8)
                            Text(nameFor(entry.counterpartyMemberID))
                            Spacer()
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                    }
                }
            }

            // Collect from
            SectionBox(title: "Collect from") {
                if balance.collectFrom.isEmpty {
                    Text("Nothing to collect")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.gray)
                } else {
                    ForEach(balance.collectFrom) { entry in
                        HStack(spacing: 0) {
                            Text(nameFor(entry.counterpartyMemberID))
                                .frame(width: 110, alignment: .leading)
                            Text("=")
                                .padding(.horizontal, 8)
                            Text(formatRupiah(entry.amount))
                            Spacer()
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
        )
    }

    private func formatRupiah(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "Rp \(formatted)"
    }
}

#Preview {
    let container = Seeders.previewContainer()
    let context = container.mainContext
    let groups = try! context.fetch(FetchDescriptor<Group>())
    let group = groups.first ?? Group(name: "Malang Trip")

    ScrollView {
        GroupSplitPDFView(group: group)
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

private struct SectionBox<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.22, green: 0.22, blue: 0.23))
        )
    }
}
