//
//  SplitInWidgetEntryView.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import SwiftUI
import WidgetKit

// Root view yang memilih layout widget berdasarkan ukuran.
struct SplitInWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme

    let entry: SplitInWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                MediumSplitInWidgetView(entry: entry)

            case .systemSmall:
                SmallSplitInWidgetView(entry: entry)

            default:
                SmallSplitInWidgetView(entry: entry)
            }
        }
        .id(colorScheme)
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}
