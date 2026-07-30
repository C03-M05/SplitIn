//
//  BillList.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import SwiftUI

// Menampilkan daftar bill terbaru pada widget ukuran medium.
struct BillList: View {
    let bills: [SplitInWidgetBillSnapshot]
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 5 * scale) {
            if bills.isEmpty {
                Text("No bills yet")
                    .font(.system(size: 15 * scale, weight: .regular))
                    .foregroundStyle(WidgetTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(Array(bills.prefix(4))) { bill in
                    HStack(spacing: 8 * scale) {
                        Text(bill.name)
                            .lineLimit(1)

                        Spacer(minLength: 5 * scale)

                        Text(bill.displayAmount)
                            .lineLimit(1)
                    }
                    .font(.system(size: 15 * scale, weight: .regular))
                    .foregroundStyle(WidgetTheme.primaryText.opacity(0.92))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
