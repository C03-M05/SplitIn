//
//  WidgetBackground.swift
//  SplitInWidget
//

import SwiftUI

struct WidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.17, green: 0.17, blue: 0.18),
                Color(red: 0.06, green: 0.06, blue: 0.07)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
