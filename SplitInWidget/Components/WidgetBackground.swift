//
//  WidgetBackground.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import SwiftUI
import UIKit

enum WidgetTheme {
    static let backgroundTop = adaptiveColor(
        light: .systemBackground,
        dark: UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)
    )
    static let backgroundBottom = adaptiveColor(
        light: .systemBackground,
        dark: UIColor(red: 0.06, green: 0.06, blue: 0.07, alpha: 1)
    )
    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let contentBackground = adaptiveColor(
        light: UIColor.white.withAlphaComponent(0.54),
        dark: UIColor.black.withAlphaComponent(0.10)
    )
    static let contentStroke = adaptiveColor(
        light: UIColor.black.withAlphaComponent(0.08),
        dark: UIColor.white.withAlphaComponent(0.15)
    )
    static let shadow = adaptiveColor(
        light: UIColor.black.withAlphaComponent(0.12),
        dark: UIColor.black.withAlphaComponent(0.30)
    )

    private static func adaptiveColor(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

// Background yang digunakan oleh seluruh widget.
struct WidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [WidgetTheme.backgroundTop, WidgetTheme.backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
