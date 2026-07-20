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

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(Array(group.bills.enumerated()), id: \.element.id) { index, bill in
                BillPDFSection(bill: bill, index: index + 1, total: group.bills.count)
                    .cardStyle(padding: 20)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appBackground)
    }
}

/// One bill rendered as a standalone page — used to give each bill its own PDF page.
struct BillPDFPage: View {
    let bill: Bill
    let index: Int
    let total: Int

    var body: some View {
        BillPDFSection(bill: bill, index: index, total: total)
            .cardStyle(padding: 20)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appBackground)
    }
}

// MARK: - Per-bill section (mirrors BillDetailSheet's content)

private struct BillPDFSection: View {
    let bill: Bill
    let index: Int
    let total: Int

    private var displaySubtotal: Decimal {
        bill.subTotal ?? bill.items.reduce(Decimal(0)) { $0 + $1.totalPrice }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Bill N of Total
            Text("Bill \(index) of \(total)")
                .font(.captionText)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textSecondary)

            // Nama Bill + Pembayar
            VStack(alignment: .leading, spacing: 6) {
                Text(bill.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Paid by \(bill.paidBy.person.name.capitalized)")
                    .font(.bodyText)
                    .foregroundStyle(Color.textPrimary)
            }

            Divider()
                .background(Color.textPrimary.opacity(0.3))

            // MARK: - Section Items
            VStack(alignment: .leading, spacing: 20) {
                Text("Items")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                ForEach(bill.items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.cardLabel)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(alignment: .bottom) {
                            HStack(spacing: 16) {
                                Text(formatRupiah(item.price))
                                    .foregroundStyle(Color.textPrimary)

                                Text("x \(formattedQuantity(item.quantity))")
                                    .foregroundStyle(Color.textPrimary)
                            }
                            .font(.bodyText)

                            Spacer()

                            Text(formatRupiah(item.totalPrice))
                                .font(.bodyText)
                                .foregroundStyle(Color.textPrimary)
                        }

                        let memberNames = item.splits
                            .map { $0.member.person.name.lowercased() }
                            .joined(separator: ", ")

                        Text(memberNames)
                            .font(.captionText)
                            .foregroundStyle(Color.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 2)
                    }
                }
            }

            Divider()
                .background(Color.textPrimary.opacity(0.3))

            // MARK: - Section Total
            VStack(alignment: .leading, spacing: 16) {
                Text("Total")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                VStack(spacing: 12) {
                    HStack {
                        Text("Total Bill")
                            .font(.bodyText)
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        Text(formatRupiah(displaySubtotal))
                            .font(.bodyText)
                            .foregroundStyle(Color.textPrimary)
                    }

                    HStack {
                        Text("After Tax/Discounts")
                            .font(.bodyText)
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        Text(formatRupiah(bill.totalFinal ?? displaySubtotal))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)
                    }
                }
            }
        }
    }

    private func formattedQuantity(_ quantity: Decimal) -> String {
        "\(NSDecimalNumber(decimal: quantity).intValue)"
    }
}

// MARK: - Shared helpers

private func formatRupiah(_ amount: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "id_ID")
    formatter.groupingSeparator = "."
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    let formatted = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    return "Rp \(formatted)"
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
