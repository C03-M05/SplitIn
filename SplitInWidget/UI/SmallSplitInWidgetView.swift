//
//  SmallSplitInWidgetView.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import AppIntents
import SwiftUI

// Tampilan small widget dengan judul group dan dua tombol aksi utama.
struct SmallSplitInWidgetView: View {
    let entry: SplitInWidgetEntry

    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / 170, proxy.size.height / 170)
            let group = entry.group

            VStack(alignment: .leading, spacing: 9 * scale) {
                Text(group?.name ?? "No Group")
                    .font(.system(size: 27 * scale, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)

                Spacer(minLength: 2 * scale)

                Link(destination: addBillURL(for: group?.id)) {
                    WidgetActionCapsule(
                        title: "Add Bill",
                        style: .orange,
                        height: 43 * scale,
                        fontSize: 20 * scale
                    )
                }
                .disabled(group == nil)

                Button(intent: CopyChecklistIntent(groupID: group?.id)) {
                    WidgetActionCapsule(
                        title: "Copy List",
                        style: .grey,
                        height: 42 * scale,
                        fontSize: 20 * scale
                    )
                }
                .buttonStyle(.plain)
                .disabled(group == nil)
            }
            .padding(16 * scale)
        }
    }
}
