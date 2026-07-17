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
    @State private var showDeleteConfirmation = false
    @State private var showCancelConfirmation = false
    @State private var itemIDToDelete: UUID?
    
    init(group: Group) {
        _viewModel = State(initialValue: CreateBillViewModel(group: group))
    }

    init(bill: Bill) {
        _viewModel = State(initialValue: CreateBillViewModel(bill: bill))
    }
    
    var body: some View {
        @Bindable var vm = viewModel
        
        VStack(spacing: 0) {
            // Header Navigasi
            TopNavigationBar(
                title: vm.isEditMode ? "Edit Bill" : "Create Bill",
                isComplete: vm.isFormValid,
                onCancel: {
                    let hasStartedTyping = !vm.billName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    let hasAddedPrices = vm.formItems.contains { $0.price > 0 || !$0.name.isEmpty }
                    
                    if hasStartedTyping || hasAddedPrices {
                        showCancelConfirmation = true
                    } else {
                        dismiss()
                    }
                },
                onSave: {
                    vm.saveBill(modelContext: modelContext)
                    dismiss()
                }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Judul Bill
                    Text("Bill")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Input Nama Bill
                    TextField("Bill name", text: $vm.billName)
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
                            //vm.removeItem(id: vm.formItems[index].id)
                            itemIDToDelete = vm.formItems[index].id
                            showDeleteConfirmation = true
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
                            Text("Total Items")
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
                                
                                let dynamicPlaceholder = vm.totalBillAmount == 0 ? "0" : vm.formatToRupiah(vm.totalBillAmount).replacingOccurrences(of: "Rp ", with: "")
                                
                                TextField(dynamicPlaceholder, text: $vm.manualGrandTotal)
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
            // ALERT 1: Konfirmasi Hapus Item Menu
            .alert("Delete Item", isPresented: $showDeleteConfirmation) {
                Button("Close", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let id = itemIDToDelete {
                        vm.removeItem(id: id)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this item?")
            }
        }
            
            // ALERT 2: Konfirmasi button Close X
            .alert("Batalkan Nota?", isPresented: $showCancelConfirmation) {
                Button("Lanjutkan Mengisi", role: .cancel) { }
                Button("Buang", role: .destructive) {
                    dismiss()
            }
        } message: {
            Text("Perubahan yang Anda buat belum disimpan. Apakah Anda yakin ingin membuang nota ini?")
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
                        Image(systemName: "trash.fill").foregroundColor(.red)
                    }
                }
            }
            
            TextField("Name", text: $item.name)
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(8)
            
            HStack(spacing: 16) {
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
                .frame(maxWidth: .infinity)
                
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
