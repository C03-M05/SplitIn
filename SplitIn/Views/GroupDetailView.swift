//
//  GroupDetailView.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 16/07/26.
//

import SwiftUI
import SwiftData

struct GroupDetailView: View {
    @ObservedObject var viewModel: GroupDetailViewModel
    var onBack: () -> Void

    @StateObject private var repaymentVM: RepaymentChecklistViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedBill: Bill?

    // ♿ Aksesibilitas: ukuran tombol Add Bill mengikuti Dynamic Type
    @ScaledMetric(relativeTo: .body) private var addButtonBottomPad: CGFloat = 20

    init(viewModel: GroupDetailViewModel, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
        _repaymentVM = StateObject(wrappedValue: RepaymentChecklistViewModel(group: viewModel.group))
    }

    var body: some View {
        VStack(spacing: 0) {
            GroupDetailTopNavigationBar(onBack: onBack, viewModel: repaymentVM)

            SwiftUI.Group {
                if viewModel.sortedBills.isEmpty {
                    emptyBillsState
                } else {
                    contentList
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack {
                    Spacer()
                    Button("Add Bill") {
                        // TODO: Navigate to CreateBillView
                    }
                    .buttonStyle(.primary)
                    .accessibilityLabel("Tambah Tagihan")
                    .accessibilityHint("Ketuk untuk menambahkan tagihan baru ke grup ini")
                    .padding(.trailing, 20)
                    .padding(.vertical, addButtonBottomPad)
                }
            }
        }
        .background(Color.appBackground)
        .overlay {
            if viewModel.showDeleteAlert {
                deleteConfirmationOverlay
            }
        }
        .sheet(item: $selectedBill) { bill in
            BillDetailSheet(bill: bill) {
                selectedBill = nil
            }
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Empty State
    private var emptyBillsState: some View {
        VStack(spacing: 0) {
            Text(viewModel.group.name)
                .font(.screenTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Text("add bill")
                .font(.bodyText)
                .foregroundStyle(Color.textSecondary)
                .accessibilityLabel("Belum ada tagihan, ketuk Add Bill untuk menambahkan")

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    // MARK: - Content List (when bills exist)
    private var contentList: some View {
        List {
            // MARK: - Group Title
            Text(viewModel.group.name)
                .font(.screenTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .listRowBackground(Color.appBackground)
                .listRowSeparator(.hidden)
                .padding(.top, 8)
                .accessibilityAddTraits(.isHeader)

            // MARK: - Split Details Header
            Text("Split Details")
                .font(.sectionHeader)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)
                .listRowBackground(Color.appBackground)
                .listRowSeparator(.hidden)
                .padding(.top, 8)
                .accessibilityAddTraits(.isHeader)

            // MARK: - Member Filter
            MemberFilterBar(
                members: viewModel.group.members,
                selectedMemberID: viewModel.selectedMemberID,
                onSelect: viewModel.selectMember
            )
            .listRowBackground(Color.appBackground)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())

            // MARK: - Balance Cards
            if let balance = viewModel.selectedMemberBalance {
                let payToRows: [SummaryRow] = balance.payTo.isEmpty
                    ? [SummaryRow("All settled up", isPlaceholder: true)]
                    : balance.payTo.map { entry in
                        SummaryRow(
                            "\(viewModel.formattedRupiah(entry.amount)) → \(viewModel.memberName(for: entry.counterpartyMemberID))"
                        )
                    }
                SplitSummaryCard(title: "Pay to", rows: payToRows)
                    .listRowBackground(Color.appBackground)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))

                let collectRows: [SummaryRow] = balance.collectFrom.isEmpty
                    ? [SummaryRow("Nothing to collect", isPlaceholder: true)]
                    : balance.collectFrom.map { entry in
                        SummaryRow(
                            viewModel.memberName(for: entry.counterpartyMemberID),
                            trailing: viewModel.formattedRupiah(entry.amount)
                        )
                    }
                SplitSummaryCard(title: "Collect from", rows: collectRows)
                    .listRowBackground(Color.appBackground)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
            }

            // MARK: - Bills Header
            Text("Bills")
                .font(.sectionHeader)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)
                .listRowBackground(Color.appBackground)
                .listRowSeparator(.hidden)
                .padding(.top, 8)
                .accessibilityAddTraits(.isHeader)

            // MARK: - Bill Rows
            ForEach(viewModel.sortedBills) { bill in
                BillRowView(
                    bill: bill,
                    displayTotal: viewModel.billDisplayTotal(bill),
                    formattedDate: viewModel.formattedDate(bill.billDate),
                    onTap: { selectedBill = bill },
                    onDelete: { viewModel.requestDelete(bill: bill) }
                )
                .listRowBackground(Color.appBackground)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
    }

    // MARK: - Custom Delete Confirmation Dialog
    private var deleteConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Delete Bill")
                        .font(.cardLabel)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    Text("This action cannot be undone")
                        .font(.bodyText)
                        .foregroundStyle(Color.textSecondary)
                }

                VStack(spacing: 10) {
                    Button("Cancel") {
                        viewModel.showDeleteAlert = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .font(.cardLabel)
                    .fontWeight(.semibold)
                    .clipShape(Capsule())
                    .buttonStyle(.plain)
                    .accessibilityLabel("Batalkan penghapusan")

                    Button("Delete") {
                        viewModel.confirmDelete(using: modelContext)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5))
                    .foregroundStyle(Color.destructiveRed)
                    .font(.cardLabel)
                    .fontWeight(.semibold)
                    .clipShape(Capsule())
                    .buttonStyle(.plain)
                    .accessibilityLabel("Konfirmasi hapus tagihan")
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal, 32)
        }
    }
}

#Preview("With Bills") {
    let container = Seeders.previewContainer()
    let context = container.mainContext
    let groups = try! context.fetch(FetchDescriptor<Group>())
    let group = groups.first ?? Group(name: "Malang Trip")
    let vm = GroupDetailViewModel(group: group)

    return GroupDetailView(viewModel: vm, onBack: { print("Back tapped") })
        .modelContainer(container)
        .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    let schema = Schema([Group.self, Person.self, GroupMember.self, Bill.self, BillItem.self, ItemSplit.self, Settlement.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext

    let emptyGroup = Group(name: "Malang Trip")
    context.insert(emptyGroup)
    let person = Person(name: "axel")
    context.insert(person)
    let member = GroupMember(group: emptyGroup, person: person)
    context.insert(member)
    emptyGroup.members.append(member)

    let vm = GroupDetailViewModel(group: emptyGroup)

    return GroupDetailView(viewModel: vm, onBack: {})
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
