//
//  WidgetActionCapsule.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import SwiftUI

// Komponen tombol untuk aksi widget.
struct WidgetActionCapsule: View {
    enum Style {
        case orange
        case grey
    }

    let title: String
    let style: Style
    let height: CGFloat
    let fontSize: CGFloat

    private var gradientColours: [Color] {
        switch style {
        case .orange:
            return [
                Color(red: 1.00, green: 0.61, blue: 0.19),
                Color(red: 1.00, green: 0.50, blue: 0.12)
            ]

        case .grey:
            return [
                Color(red: 0.63, green: 0.63, blue: 0.64),
                Color(red: 0.48, green: 0.48, blue: 0.50)
            ]
        }
    }

    private var titleColour: Color {
        style == .orange ? .white.opacity(0.90) : .white
    }

    var body: some View {
        Text(title)
            .font(.system(size: fontSize, weight: .regular))
            .foregroundStyle(titleColour)
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: gradientColours,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        Capsule()
                            .stroke(Color.white.opacity(0.20), lineWidth: 1)
                    }
                    .shadow(
                        color: WidgetTheme.shadow,
                        radius: 5,
                        x: 0,
                        y: 4
                    )
            }
    }
}
