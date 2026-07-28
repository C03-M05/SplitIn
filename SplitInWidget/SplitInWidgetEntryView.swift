//
//  SplitInWidgetEntryView.swift
//  SplitInWidget
//

import SwiftUI
import WidgetKit

struct SplitInWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

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
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}
