//
//  CreateBillView.swift
//  SplitIn
//
//  Created by Miranda Utami on 14/07/26.
//

import SwiftUI
import SwiftData

struct CreateBillView: View {
    // MARK: - Environment & State
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CreateBillViewModel
    
    init(group: Group) {
        _viewModel = State(initialValue: CreateBillViewModel(group: group))
    }
    
    var body: some View {
        @Bindable var vm = viewModel
        
        VStack(spacing: 0) {
            // Header Navigasi
            TopNavigationBar(
                title: "Create Bill",
                isComplete: vm.isFormValid,
                onCancel: { dismiss() },
                onSave: {
                    vm.saveBill(modelContext: modelContext)
                    dismiss()
                }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Input Nama Bill
                    TextField("bill name", text: $vm.billName)
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
                            Picker("", selection: $vm.selectedPayer) {
                                Text("Payer").tag(GroupMember?.none)
                                ForEach(vm.currentGroup.members) { member in
                                    Text(member.person.name).tag(GroupMember?.some(member))
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(vm.selectedPayer?.person.name ?? "Payer")
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
                    
                    // Judul items
                    Text("Items")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Looping index items
                    ForEach(0..<vm.formItems.count, id: \.self) { index in
                        BillItemRow(
                            item: $vm.formItems[index],
                            members: vm.currentGroup.members,
                            showDeleteButton: vm.formItems.count > 1
                        ) {
                            vm.removeItem(id: vm.formItems[index].id)
                        }
                    }
                    
                    Button(action: { vm.addItem() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("add more")
                        }
                        .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                        .background(Color(.systemGray6))
                    
                    // MARK: - Section Total
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Total")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Bill")
                                .font(.caption)
                            Text(vm.formatToRupiah(vm.totalBillAmount))
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total after tax & discounts")
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 4) {
                                Text("Rp")
                                    .foregroundColor(.secondary)
                                    .fontWeight(.semibold)
                                
                                TextField("0", text: $vm.manualGrandTotal)
                                    .keyboardType(.numberPad)
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGray6))
        }
    }
}

// MARK: - Subview Baris Menu Item
struct BillItemRow: View {
    @Binding var item: FormItemInput
    let members: [GroupMember]
    let showDeleteButton: Bool
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Item \(item.displayIndex)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                if showDeleteButton {
                    Button(action: onDelete) {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }
            }
            
            TextField("Menu", text: $item.name)
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(8)
            
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text("Rp")
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                    
                    TextField("0", text: $item.priceBindingString)
                        .keyboardType(.numberPad)
                }
                .padding(10)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .frame(maxWidth: 160)
                
                Spacer()
                AppStepper(quantity: $item.quantity)
            }
            
            // Member
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(members) { member in
                        let isSelected = item.assignedMemberIDs.contains(member.id)
                        let initial = String(member.person.name.prefix(1)).uppercased()
                        
                        VStack(spacing: 4) {
                            Text(initial)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(isSelected ? Color(.systemBackground) : .primary)
                                .frame(width: 67, height: 67)
                                .background(isSelected ? Color.primary : Color(.systemGray5))
                                .clipShape(Circle())
                            
                            Text(member.person.name)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            if isSelected {
                                item.assignedMemberIDs.remove(member.id)
                            } else {
                                item.assignedMemberIDs.insert(member.id)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Komponen Stepper Terpisah
struct AppStepper: View {
    @Binding var quantity: Int
    var body: some View {
        HStack(spacing: 16) {
            Button(action: { if quantity > 1 { quantity -= 1 } }) {
                Image(systemName: "minus").bold()
            }
            Text("\(quantity)").fontWeight(.semibold)
            Button(action: { quantity += 1 }) {
                Image(systemName: "plus").bold()
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .cornerRadius(20)
    }
}

// MARK: - Preview Generator
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Group.self, Person.self, GroupMember.self, configurations: config)
    let context = container.mainContext
    
    let previewGroup = Group(name: "Patungan Makan")
    context.insert(previewGroup)
    
    let sampleNames = ["Farhan", "Sherin", "Miranda", "Axel", "Theo"]
    for name in sampleNames {
        let person = Person(name: name)
        let member = GroupMember(group: previewGroup, person: person)
        context.insert(person)
        context.insert(member)
        previewGroup.members.append(member)
    }
    
    return CreateBillView(group: previewGroup)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}



//import SwiftUI
//import SwiftData
//
//struct CreateBillView: View {
//    // MARK: - Properties
//    @State private var billName: String = ""
//    @State private var selectedPayer: String = "miranda"
//    @State private var billDate: Date = Date()
//    @State private var items: [LocalBillItem] = [LocalBillItem()]
//    @State private var manualGrandTotal: String = ""
//
//
//    // MARK: - Data Dummy Member
//    let dummyPayers = ["farhan", "sherin", "miranda", "axel", "theo"]
//
//    // MARK: - Validation
//    private var isFormValid: Bool {
//        // 1. Memastikan bill name tidak kosong
//        let isBillNameFilled = !billName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//
//        // 2. Memastikan seluruh item makanan di dalam daftar sudah diisi dengan benar
//        let areItemsValid = !items.isEmpty && items.allSatisfy { item in
//            let hasName = !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//            let hasPrice = (Double(item.price) ?? 0) > 0
//            let hasQuantity = item.quantity > 0
//            let hasMembers = !item.assignedMembers.isEmpty
//            return hasName && hasPrice && hasQuantity && hasMembers
//        }
//
//        // 3. Memastikan nominal akhir setelah pajak/diskon juga sudah diisi
//        let isGrandTotalFilled = !manualGrandTotal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//
//        // Nota dianggap valid HANYA jika ketiga syarat di atas terpenuhi semua
//        return isBillNameFilled && areItemsValid && isGrandTotalFilled
//    }
//
//    // MARK: - Body View
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header Navigasi
//            TopNavigationBar(
//                title: "Create Bill",
//                isComplete: isFormValid,
//                onCancel: { print("Proses Batal") },
//                onSave: { print("Proses Simpan") }
//            )
//
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//
//                    // Input Nama Bill
//                    // belum ada validasi input
//                    TextField("bill name", text: $billName)
//                        .padding()
//                        .background(Color(.systemGray5))
//                        .cornerRadius(14)
//                    // ♿ Aksesibilitas: Memberikan label kontekstual untuk pembaca layar
//                    .accessibilityLabel("Bill Name")
//                    .accessibilityHint("Ketik nama untuk nota belanja ini")
//
//                    // Pilihan Pembayar
//                    HStack {
//                        Text("Who Paid?")
//                            .foregroundColor(.primary)
//
//                        Spacer()
//
//                        Menu {
//                            Picker("", selection: $selectedPayer) {
//                                ForEach(dummyPayers, id: \.self) { payer in
//                                    Text(payer).tag(payer)
//                                }
//                            }
//                        } label: {
//                            HStack(spacing: 8) {
//                                Text(selectedPayer.isEmpty ? "Pilih" : selectedPayer)
//                                    .foregroundColor(.primary)
//
//                                Image(systemName: "chevron.down")
//                                    .font(.footnote)
//                                    .foregroundColor(.gray)
//                            }
//                            .padding(.horizontal, 10)
//                            .padding(.vertical, 8)
//                            .background(Color(.systemGray5))
//                            .cornerRadius(8)
//                        }
//                    }
//
//                    Divider()
//                        .background(Color(.systemGray6))
//
//                    // Judul Items
//                    Text("Items")
//                        .font(.title3)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//
//                    // Daftar Form Makanan
//                    // belum ada validasi input dan rupiah
//                    ForEach(items.indices, id: \.self) { index in
//                        VStack(alignment: .leading, spacing: 12) {
//                            HStack {
//                                Text("Item \(index + 1)")
//                                    .font(.subheadline)
//                                    .foregroundColor(.primary)
//                                Spacer()
//                                Button(action: { items.remove(at: index) }) {
//                                    Image(systemName: "trash")
//                                        .foregroundColor(.red)
//                                }
//                                .disabled(items.count == 1)
//                            }
//
//                            TextField("Menu", text: $items[index].name)
//                                .padding(12)
//                                .background(Color(.systemGray5))
//                                .cornerRadius(8)
//
//                            HStack(spacing: 12) {
//                                HStack {
//                                    TextField("Rp 0", text: $items[index].price)
//                                        .keyboardType(.numberPad)
//                                }
//                                .padding(10)
//                                .background(Color(.systemGray5))
//                                .cornerRadius(8)
//
//                                Spacer()
//
//                                HStack(spacing: 16) {
//                                    Button(action: { if items[index].quantity > 1 { items[index].quantity -= 1 } }) {
//                                        Image(systemName: "minus").bold()
//                                    }
//                                    Text("\(items[index].quantity)")
//                                        .fontWeight(.semibold)
//                                    Button(action: { items[index].quantity += 1 }) {
//                                        Image(systemName: "plus").bold()
//                                    }
//                                }
//                                .foregroundColor(.primary)
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 8)
//                                .background(Color(.systemGray5))
//                                .cornerRadius(20)
//                            }
//
//                            // MEMBER
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack(spacing: 14) {
//                                    ForEach(dummyPayers, id: \.self) { member in
//                                        let isSelected = items[index].assignedMembers.contains(member)
//                                        let initial = String(member.prefix(1)).uppercased()
//
//                                        VStack(spacing: 4) {
//                                            Text(initial)
//                                                .font(.title3)
//                                                .fontWeight(.bold)
//                                                .foregroundColor(isSelected ? .black : .primary)
//                                                .frame(width: 67, height: 67)
//                                                .background(isSelected ? Color.primary : Color(.systemGray5))
//                                                .clipShape(Circle())
//
//                                            Text(member)
//                                                .font(.caption2)
//                                                .foregroundColor(.secondary)
//                                        }
//                                        .onTapGesture {
//                                            if isSelected {
//                                                items[index].assignedMembers.remove(member)
//                                            } else {
//                                                items[index].assignedMembers.insert(member)
//                                            }
//                                        }
//                                    }
//                                }
//                                .padding(.top, 4)
//                            }
//                        }
//                        .padding(.bottom, 10)
//                    }
//
//                    // Tombol Add More
//                    Button(action: { items.append(LocalBillItem()) }) {
//                        HStack {
//                            Image(systemName: "plus.circle.fill")
//                            Text("add more")
//                        }
//                        .foregroundColor(.orange)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .center)
//
//                    Divider()
//                        .background(Color(.systemGray6))
//
//                    // Section Total
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Total")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .foregroundColor(.primary)
//
//                        // 1. Tampilan Total Bill Otomatis
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Total Bill")
//                                .font(.caption)
//                                .foregroundColor(.primary)
//                            Text("Rp 0")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                        }
//
//                        // 2. Input manual untuk Total setelah Pajak & Diskon
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Total after tax & discounts")
//                                .font(.caption)
//                                .foregroundColor(.primary)
//
//                            TextField("Rp 0", text: $manualGrandTotal)
//                                .keyboardType(.numberPad)
//                                .padding()
//                                .background(Color(.systemGray5))
//                                .cornerRadius(12)
//                                .foregroundColor(.white)
//                        }
//                    }
//                }
//                .padding(20)
//            }
//            .background(Color(.systemGray6))
//        }
//    }
//}
//
//
//// MARK: - Data Model (Dummy)
//struct LocalBillItem: Identifiable {
//    let id = UUID()
//    var name: String = ""
//    var price: String = ""
//    var quantity: Int = 1
//    var assignedMembers: Set<String> = []
//}
//
//#Preview {
//    CreateBillView()
//}
