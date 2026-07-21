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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Nama Bill + Pembayar
                    VStack(alignment: .leading, spacing: 6) {
                        Text(bill.name)
                            .font(.sectionHeader)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Paid by \(bill.paidBy.person.name.capitalized)")
                            .font(.bodyText)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.top, 8)
                    
                    Divider()
                        .background(Color.textPrimary.opacity(0.2))

                    // MARK: - Section Items
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Items")
                            .font(.sectionHeader)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)

                        ForEach(bill.items) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.cardLabel)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)

                                HStack(alignment: .bottom) {
                                    HStack(spacing: 16) {
                                        Text(formattedRupiah(item.price))
                                        Text("x \(formattedQuantity(item.quantity))")
                                    }
                                    .font(.bodyText)
                                    .foregroundStyle(Color.textPrimary)

                                    Spacer()

                                    Text(formattedRupiah(item.totalPrice))
                                        .font(.bodyText)
                                        .foregroundStyle(Color.textPrimary)
                                }

                                let memberNames = item.splits
                                    .map { $0.member.person.name.lowercased() }
                                    .joined(separator: ", ")
                                
                                Text(memberNames)
                                    .font(.captionText)
                                    .foregroundStyle(Color.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 2)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }

                    Divider()
                        .background(Color.textPrimary.opacity(0.2))

                    // MARK: - Section Total
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Total")
                            .font(.sectionHeader)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)

                        VStack(spacing: 12) {
                            HStack {
                                Text("Total Bill")
                                    .font(.bodyText)
                                    .foregroundStyle(Color.textPrimary)
                                Spacer()
                                Text(formattedRupiah(displaySubtotal))
                                    .font(.bodyText)
                                    .foregroundStyle(Color.textPrimary)
                            }
                            .accessibilityElement(children: .combine)

                            HStack {
                                Text("After Tax/Discounts")
                                    .font(.bodyText)
                                    .foregroundStyle(Color.textPrimary)
                                Spacer()
                                Text(formattedRupiah(bill.totalFinal ?? displaySubtotal))
                                    .font(.sectionSubheader)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.textPrimary)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.appBackground)
            .navigationTitle("Bill Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.textPrimary)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showEditBill = true }) {
                        Image(systemName: "pencil")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.textPrimary)
                    }
                }
            }
        }
        // Atur tinggi modal bawaan di sini
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
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
        .preferredColorScheme(.dark)
        .modelContainer(container)
}
