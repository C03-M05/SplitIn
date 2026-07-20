//
//  BillRowView.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 16/07/26.
//

import SwiftUI
import SwiftData

struct BillRowView: View {
    let bill: Bill
    let displayTotal: String
    let formattedDate: String
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bill.name)
                        .font(.cardLabel)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(formattedDate)
                        .font(.captionText)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Text(displayTotal)
                    .font(.sectionHeader)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash.fill")
            }
            .accessibilityLabel("Delete \(bill.name)")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(bill.name), \(displayTotal)")
        .accessibilityHint("Tap to view details, swipe left to delete")
    }
}

#Preview {
    let container = Seeders.previewContainer()
    let context = container.mainContext
    let bills = try! context.fetch(FetchDescriptor<Bill>())
    let bill = bills.first!

    return List {
        BillRowView(
            bill: bill,
            displayTotal: "65k",
            formattedDate: "28/06/2026 18:03",
            onTap: {},
            onDelete: {}
        )
    }
    .listStyle(.plain)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
    .modelContainer(container)
}
