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
                                .background(.ultraThinMaterial, in: Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                    )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Tutup")
                        .accessibilityHint("Tutup lembar detail tagihan")

                        Spacer()

                        Button(action: { showEditBill = true }) {
                            Image(systemName: "pencil")
                                .bold()
                                .foregroundStyle(Color.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(Color(.white).opacity(0.15))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Ubah")
                        .accessibilityHint("Edit informasi detail tagihan ini")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                // MARK: - Content Scroll View
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Nama Bill + Pembayar
                        VStack(alignment: .leading, spacing: 6) {
                            Text(bill.name)
                                .font(.sectionHeader)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Paid by \(bill.paidBy.person.name.capitalized)")
                                .font(.bodyText)
                                .foregroundStyle(Color.textPrimary)
                        }
                        .padding(.top, 8)
                        
                        Divider()
                            .background(Color.textPrimary.opacity(0.3))

                        // MARK: - Section Items
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Items")
                                .font(.sectionHeader)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.textPrimary)

                            ForEach(bill.items) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    // Baris Judul Item
                                    Text(item.name)
                                        .font(.cardLabel)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)

                                    // Baris Detail Harga & Total Sesuai Gambar Mockup
                                    HStack(alignment: .bottom) {
                                        HStack(spacing: 16) {
                                            Text(formattedRupiah(item.price))
                                                .foregroundStyle(Color.textPrimary)
                                            
                                            Text("x \(formattedQuantity(item.quantity))")
                                                .foregroundStyle(Color.textPrimary)
                                        }
                                        .font(.bodyText)

                                        Spacer()

                                        // Total harga per item (Price * Quantity)
                                        Text(formattedRupiah(item.totalPrice))
                                            .font(.bodyText)
                                            .foregroundStyle(Color.textPrimary)
                                    }

                                    // Nama-nama pemisah split belanjaan
                                    let memberNames = item.splits
                                        .map { $0.member.person.name.lowercased() }
                                        .joined(separator: ", ")
                                    
                                    Text(memberNames)
                                        .font(.captionText)
                                        .foregroundStyle(Color.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.top, 2)
                                }
                                .accessibilityElement(children: .combine)
                            }
                        }

                        Divider()
                            .background(Color.textPrimary.opacity(0.3))

                        // MARK: - Section Total
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Total")
                                .font(.sectionHeader)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.textPrimary)

                            VStack(spacing: 12) {
                                // Baris Subtotal Tagihan Kotor
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

                                // Baris Tagihan Bersih Setelah Pajak/Diskon
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
