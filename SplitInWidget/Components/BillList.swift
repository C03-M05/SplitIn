//
//  BillList.swift
//  SplitInWidget
//

import SwiftUI

struct BillList: View {
    let bills: [SplitInWidgetBillSnapshot]
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 5 * scale) {
            if bills.isEmpty {
                Text("No bills yet")
                    .font(.system(size: 15 * scale, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.7))
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
                    .foregroundStyle(Color.white.opacity(0.92))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
