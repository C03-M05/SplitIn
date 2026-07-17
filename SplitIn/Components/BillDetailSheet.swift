//
//  BillDetailSheet.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 16/07/26.
//

import SwiftUI
import SwiftData

struct BillDetailSheet: View {
    let bill: Bill
    let onClose: () -> Void

    @State private var showEditBill = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                ZStack {
                    Text("Bill Details")
                        .font(.cardLabel)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    HStack {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .bold()
                                .foregroundStyle(Color.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray4))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Tutup")
                        .accessibilityHint("Tutup detail tagihan")

                        Spacer()

                        Button(action: { showEditBill = true }) {
                            Image(systemName: "pencil")
                                .bold()
                                .foregroundStyle(Color.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray4))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Edit tagihan")
                        .accessibilityHint("Edit detail tagihan ini")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Divider()
                    .background(Color.textSecondary)

                // MARK: - Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Bill name + payer
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bill.name)
                                .font(.sectionHeader)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Paid by \(bill.paidBy.person.name.capitalized)")
                                .font(.bodyText)
                                .foregroundStyle(Color.textPrimary)
                        }

                        Divider()
                            .background(Color.textSecondary)

                        // Items
                        Text("Items")
                            .font(.sectionHeader)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)

                        ForEach(Array(bill.items.enumerated()), id: \.element.id) { index, item in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .top) {
                                    Text(item.name)
                                        .font(.cardLabel)
                                        .foregroundStyle(Color.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Spacer()

                                    Text("x \(formattedQuantity(item.quantity))")
                                        .font(.bodyText)
                                        .foregroundStyle(Color.textPrimary)
                                }

                                Text(formattedRupiah(item.price))
                                    .font(.bodyText)
                                    .foregroundStyle(Color.textPrimary)

                                let memberNames = item.splits
                                    .map { $0.member.person.name.lowercased() }
                                    .joined(separator: ", ")
                                Text(memberNames)
                                    .font(.captionText)
                                    .foregroundStyle(Color.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .accessibilityElement(children: .combine)
                        }

                        // MARK: - Total Section
                        Divider()
                            .background(Color.textSecondary)
                            .padding(.vertical, 4)

                        Text("Total")
                            .font(.sectionHeader)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)

                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total Bill")
                                    .font(.captionText)
                                    .foregroundStyle(Color.textSecondary)
                                Text(formattedRupiah(displaySubtotal))
                                    .font(.cardLabel)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.textPrimary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total after tax & discounts")
                                    .font(.captionText)
                                    .foregroundStyle(Color.textSecondary)
                                Text(formattedRupiah(bill.totalFinal ?? displaySubtotal))
                                    .font(.cardLabel)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.textPrimary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                    .padding(20)
                }
            }
        }
        .sheet(isPresented: $showEditBill) {
            CreateBillView(bill: bill)
        }
    }

    private var displaySubtotal: Decimal {
        bill.subTotal ?? bill.items.reduce(Decimal(0)) { $0 + $1.totalPrice }
    }

    private func formattedRupiah(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "Rp \(formatted)"
    }

    private func formattedQuantity(_ quantity: Decimal) -> String {
        "\(NSDecimalNumber(decimal: quantity).intValue)"
    }
}

#Preview {
    let container = Seeders.previewContainer()
    let context = container.mainContext
    let bills = try! context.fetch(FetchDescriptor<Bill>())
    let bill = bills.last!

    return BillDetailSheet(bill: bill, onClose: {})
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        .modelContainer(container)
}
