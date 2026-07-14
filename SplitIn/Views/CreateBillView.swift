//
//  CreateBillView.swift
//  SplitIn
//
//  Created by Miranda Utami on 14/07/26.
//

import SwiftUI

struct CreateBillView: View {
    // MARK: - Properties
    @State private var billName: String = ""
    @State private var selectedPayer: String = "miranda"
    @State private var billDate: Date = Date()
    @State private var items: [LocalBillItem] = [LocalBillItem()]
    @State private var manualGrandTotal: String = ""
    
    // MARK: - Data Dummy Member
    let dummyPayers = ["farhan", "sherin", "miranda", "axel", "theo"]
    
    // MARK: - Validation
    private var isFormValid: Bool {
        // 1. Memastikan nama nota (bill name) tidak kosong
        let isBillNameFilled = !billName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // 2. Memastikan seluruh item makanan di dalam daftar sudah diisi dengan benar
        let areItemsValid = !items.isEmpty && items.allSatisfy { item in
            let hasName = !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasPrice = (Double(item.price) ?? 0) > 0
            let hasQuantity = item.quantity > 0
            let hasMembers = !item.assignedMembers.isEmpty
            return hasName && hasPrice && hasQuantity && hasMembers
        }
        
        // 3. Memastikan nominal akhir setelah pajak/diskon juga sudah diisi
        let isGrandTotalFilled = !manualGrandTotal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Nota dianggap valid HANYA jika ketiga syarat di atas terpenuhi semua
        return isBillNameFilled && areItemsValid && isGrandTotalFilled
    }
    
    
    // MARK: - Body View
    var body: some View {
        VStack(spacing: 0) {
            // Header Navigasi
            TopNavigationBar(
                title: "Create Bill",
                isComplete: isFormValid,
                onCancel: { print("Proses Batal") },
                onSave: { print("Proses Simpan") }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Input Nama Bill
                    // belum ada validasi input
                    TextField("bill name", text: $billName)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(14)
                    // ♿ Aksesibilitas: Memberikan label kontekstual untuk pembaca layar
                    .accessibilityLabel("Bill Name")
                    .accessibilityHint("Ketik nama untuk nota belanja ini")
                    
                    // Pilihan Pembayar
                    HStack {
                        Text("Who Paid?")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Menu {
                            Picker("", selection: $selectedPayer) {
                                ForEach(dummyPayers, id: \.self) { payer in
                                    Text(payer).tag(payer)
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(selectedPayer.isEmpty ? "Pilih" : selectedPayer)
                                    .foregroundColor(.primary)
                                
                                Image(systemName: "chevron.down")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                    
                    Divider()
                        .background(Color(.systemGray6))
                    
                    // Judul Items
                    Text("Items")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Daftar Form Makanan
                    // belum ada validasi input dan rupiah
                    ForEach(items.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Item \(index + 1)")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Button(action: { items.remove(at: index) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .disabled(items.count == 1)
                            }
                            
                            TextField("Menu", text: $items[index].name)
                                .padding(12)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            
                            HStack(spacing: 12) {
                                HStack {
                                    Text("Rp")
                                        .foregroundColor(.secondary)
                                    TextField("Harga", text: $items[index].price)
                                        .keyboardType(.numberPad)
                                }
                                .padding(10)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                                
                                Spacer()
                                
                                HStack(spacing: 16) {
                                    Button(action: { if items[index].quantity > 1 { items[index].quantity -= 1 } }) {
                                        Image(systemName: "minus").bold()
                                    }
                                    Text("\(items[index].quantity)")
                                        .fontWeight(.semibold)
                                    Button(action: { items[index].quantity += 1 }) {
                                        Image(systemName: "plus").bold()
                                    }
                                }
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray5))
                                .cornerRadius(20)
                            }
                            
                            // MEMBER ( belum bisa scroll samping)
                            HStack(spacing: 10) {
                                ForEach(dummyPayers, id: \.self) { member in
                                    let isSelected = items[index].assignedMembers.contains(member)
                                    let initial = String(member.prefix(1)).uppercased()
                                    
                                    VStack(spacing: 4) {
                                        Text(initial)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(isSelected ? .black : .primary)
                                            .frame(width: 67, height: 67)
                                            .background(isSelected ? Color.primary : Color(.systemGray5))
                                            .clipShape(Circle())
                                        
                                        Text(member)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .onTapGesture {
                                        if isSelected {
                                            items[index].assignedMembers.remove(member)
                                        } else {
                                            items[index].assignedMembers.insert(member)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.bottom, 10)
                    }
                    
                    // Tombol Add More
                    Button(action: { items.append(LocalBillItem()) }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("add more")
                        }
                        .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                        .background(Color(.systemGray6))
                    
                    // Section Total
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Total")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // 1. Tampilan Total Bill Otomatis
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Bill")
                                .font(.caption)
                                .foregroundColor(.primary)
                            Text("Rp 0")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        // 2. Input manual untuk Total setelah Pajak & Diskon
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total after tax & discounts")
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            TextField("Rp 0", text: $manualGrandTotal)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGray6))
        }
    }
}


// MARK: - Data Model (Dummy)
struct LocalBillItem: Identifiable {
    let id = UUID()
    var name: String = ""
    var price: String = ""
    var quantity: Int = 1
    var assignedMembers: Set<String> = []
}

#Preview {
    CreateBillView()
}
