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

    @State private var swipeOffset: CGFloat = 0
    private let deleteButtonWidth: CGFloat = 76  // lebar visual button merah
    private let deleteRevealWidth: CGFloat = 92  // jarak geser card (button + 16pt gap)

    var body: some View {
        ZStack(alignment: .trailing) {
            deleteButton
            cardContent
                .offset(x: swipeOffset)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(bill.name), \(displayTotal)")
        .accessibilityHint("Ketuk untuk melihat detail, geser ke kiri untuk menghapus")
    }

    // MARK: - Delete Button (rounded rect, NOT circle)
    private var deleteButton: some View {
        Button {
            resetSwipe()
            onDelete()
        } label: {
            Image(systemName: "trash.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: deleteButtonWidth, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.destructiveRed)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Hapus \(bill.name)")
        .accessibilityHint("Konfirmasi untuk menghapus tagihan ini")
    }

    // MARK: - Card Content
    private var cardContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bill.name)
                    .font(.cardLabel)
                    .foregroundStyle(Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(formattedDate)
                    .font(.captionText)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Text(displayTotal)
                .font(.cardLabel)
                .foregroundStyle(Color.textPrimary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.cardBackground)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if swipeOffset < 0 {
                resetSwipe()
            } else {
                onTap()
            }
        }
        // ♿ simultaneousGesture: allows List to scroll vertically while we handle
        // horizontal swipe. Direction check prevents vertical drags from activating.
        .simultaneousGesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < 0 {
                        swipeOffset = max(value.translation.width, -deleteRevealWidth)
                    } else if swipeOffset < 0 {
                        swipeOffset = min(swipeOffset + value.translation.width, 0)
                    }
                }
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < -(deleteRevealWidth / 2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            swipeOffset = -deleteRevealWidth
                        }
                    } else {
                        resetSwipe()
                    }
                }
        )
    }

    private func resetSwipe() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            swipeOffset = 0
        }
    }
}

#Preview {
    let container = Seeders.previewContainer()
    let context = container.mainContext
    let bills = try! context.fetch(FetchDescriptor<Bill>())
    let bill = bills.first!

    return BillRowView(
        bill: bill,
        displayTotal: "65k",
        formattedDate: "28/06/2026 18:03",
        onTap: {},
        onDelete: {}
    )
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
    .modelContainer(container)
}
