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
    @State private var showCancelConfirmation = false
    
    init(group: Group) {
        _viewModel = State(initialValue: CreateBillViewModel(group: group))
    }

    init(bill: Bill) {
        _viewModel = State(initialValue: CreateBillViewModel(bill: bill))
    }
    
    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Judul Bill
                    Text("Bill")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Input Nama Bill
                    TextField("Bill name", text: $vm.billName)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(14)
                    // ♿ Accesibility
                        .accessibilityLabel("Bill Name")
                        .accessibilityHint("Enter the name for this expense bill")
                    
                    // Pilihan Pembayar
                    HStack {
                        Text("Who Paid?")
                            .font(.cardLabel)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                        Menu {
                            Picker("", selection: $vm.selectedPayer) {
                                // Text(" Select Member ")
                                //     .tag(GroupMember?.none)
                                ForEach(vm.currentGroup.members) { member in
                                    Text(member.person.name)
                                        .tag(GroupMember?.some(member))
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(vm.selectedPayer?.person.name ?? " - ")
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.captionText)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                    // ♿ Accesibility
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Who Paid, Payer Selection")
                    .accessibilityHint(vm.selectedPayer == nil ? "Double tap to select who paid this bill" : "Current payer is \(vm.selectedPayer?.person.name ?? ""). Double tap to change")
                
                    Divider()
                        .background(Color(.systemGray6))
                    
                    // Judul items
                    Text("Items")
                        .font(.sectionHeader)
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
                    // ♿ Accesibility
                    .accessibilityLabel("Add more item")
                    .accessibilityHint("Double tap to add a new menu item row")
                    
                    Divider()
                        .background(Color(.systemGray6))
                    
                    // MARK: - Section Total
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Total")
                            .font(.sectionHeader)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("Total Bills")
                                .font(.bodyText)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(vm.formatToRupiah(vm.totalBillAmount))
                                .font(.sectionHeader)
                                .fontWeight(.bold)
                        }
                        // ♿ Accesibility
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Calculated subtotal amount is \(vm.formatToRupiah(vm.totalBillAmount))")
                        
                        HStack(spacing: 20) {
                            Text("After Tax/Disc")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
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
                        // ♿ Accesibility
                        .accessibilityLabel("Total amount after tax and discounts")
                        .accessibilityHint("Optional field. Enter final bill amount from receipt if there are extra taxes or discounts")
                    }
                    
                }
                .padding(20)
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(vm.isEditMode ? "Edit Bill" : "Create Bill")
            .toolbar {
                CreateBillToolbar(
                    title: vm.isEditMode ? "Edit Bill" : "Create Bill",
                    canSave: vm.isFormValid,
                    isShowingDiscardConfirmation: $showCancelConfirmation,
                    onCancel: {
                        let hasStartedTyping = !vm.billName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        let hasAddedPrices = vm.formItems.contains { $0.price > 0 || !$0.name.isEmpty }

                        if hasStartedTyping || hasAddedPrices {
                            showCancelConfirmation = true
                        } else {
                            dismiss()
                        }
                    },
                    onDiscardDraft: {
                        dismiss()
                    },
                    onSave: {
                        vm.saveBill(modelContext: modelContext)
                        dismiss()
                    }
                )
            }
        }
        .interactiveDismissDisabled(true)
    }
}

// MARK: - Subview Baris Menu Item
struct BillItemRow: View {
    @Binding var item: FormItemInput
    let members: [GroupMember]
    let showDeleteButton: Bool
    var onDelete: () -> Void

    @State private var isShowingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Item \(item.displayIndex)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                if showDeleteButton {
                    Button {
                        isShowingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash.fill").foregroundColor(.red)
                    }
                    .confirmationDialog(
                        "",
                        isPresented: $isShowingDeleteConfirmation,
                        titleVisibility: .hidden
                    ) {
                        Button("Delete Item", role: .destructive, action: onDelete)
                    } message: {
                        Text("This item will be removed")
                    }
                    // ♿ Accesibility
                    .accessibilityLabel("Delete Item number \(item.displayIndex)")
                }
            }
            
            TextField("Name", text: $item.name)
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                // ♿ Accesibility
                .accessibilityLabel("Item \(item.displayIndex) name")
            
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
                // ♿ Accesibility
                .accessibilityLabel("Item \(item.displayIndex) price in Rupiah")
                
                
                AppStepper(quantity: $item.quantity)
                    // ♿ Accesibility
                    .accessibilityLabel("Item \(item.displayIndex) quantity")
            }
            
            // Member
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(members) { member in
                        let isSelected = item.assignedMemberIDs.contains(member.id)
                        let initial = String(member.person.name.prefix(1)).uppercased()
                        
                        VStack(spacing: 4) {
                            Text(initial)
                                .font(.screenTitle)
                                .fontWeight(.semibold)
                                .foregroundColor(isSelected ? Color(.systemBackground) : .primary)
                                .frame(width: 67, height: 67)
                                .background(isSelected ? Color.primary : Color(.systemGray5))
                                .clipShape(Circle())
                            
                            Text(member.person.name)
                                .font(.captionText)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            if isSelected {
                                item.assignedMemberIDs.remove(member.id)
                            } else {
                                item.assignedMemberIDs.insert(member.id)
                            }
                        }
                        // ♿ Accesibility
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(member.person.name)
                        .accessibilityHint(isSelected ? "Selected. Double tap to exclude this member from splitting this item" : "Not selected. Double tap to include this member in splitting this item")
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
            // ♿ Accesibility
            .accessibilityLabel("Decrease quantity")
            
            Text("\(quantity)").fontWeight(.semibold)
            
            Button(action: { quantity += 1 }) {
                Image(systemName: "plus").bold()
            }
            // ♿ Accesibility
            .accessibilityLabel("Increase quantity")
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
