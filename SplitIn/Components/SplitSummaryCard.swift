//
//  SplitSummaryCard.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 16/07/26.
//

import SwiftUI

struct SummaryRow: Identifiable {
    let id = UUID()
    let leading: String
    let trailing: String?
    let isPlaceholder: Bool

    init(_ leading: String, trailing: String? = nil, isPlaceholder: Bool = false) {
        self.leading = leading
        self.trailing = trailing
        self.isPlaceholder = isPlaceholder
    }
}

struct SplitSummaryCard: View {
    let title: String
    let rows: [SummaryRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.cardLabel)
                .foregroundStyle(Color.textPrimary)

            ForEach(rows) { row in
                let textColor: Color = row.isPlaceholder ? Color.textSecondary : Color.textPrimary
                HStack {
                    Text(row.leading)
                        .font(.bodyText)
                        .foregroundStyle(textColor)
                        .fixedSize(horizontal: false, vertical: true)

                    if let trailing = row.trailing {
                        Spacer()
                        Text(trailing)
                            .font(.bodyText)
                            .foregroundStyle(textColor)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 16) {
        SplitSummaryCard(
            title: "Pay to",
            rows: [
                SummaryRow("Rp 15.000 → Theo"),
                SummaryRow("Rp 12.000 → Farhan")
            ]
        )

        SplitSummaryCard(
            title: "Collect from",
            rows: [
                SummaryRow("Axel", trailing: "Rp 25.000"),
                SummaryRow("Theo", trailing: "Rp 17.000")
            ]
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
