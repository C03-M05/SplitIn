//
//  CardBackground.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import SwiftUI

struct CardBackground: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.cardBackground)
            )
    }
}

extension View {
    /// Bungkus view ini dengan container card standar.
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardBackground(padding: padding))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        Text("Pay to")
            .font(.cardLabel)
            .foregroundStyle(Color.textPrimary)
        Text("Rp 30.000 → Miranda")
            .font(.bodyText)
            .foregroundStyle(Color.textSecondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .cardStyle()
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}
