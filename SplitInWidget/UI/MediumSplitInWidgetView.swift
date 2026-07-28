//
//  MediumSplitInWidgetView.swift
//  SplitInWidget
//

import AppIntents
import SwiftUI

struct MediumSplitInWidgetView: View {
    let entry: SplitInWidgetEntry

    var body: some View {
        GeometryReader { proxy in
            let widthScale = proxy.size.width / 364
            let heightScale = proxy.size.height / 169
            let scale = min(widthScale, heightScale)
            let group = entry.group

            VStack(spacing: 9 * scale) {
                HStack(spacing: 12 * scale) {
                    Text(group?.name ?? "No Group")
                        .font(.system(size: 29 * scale, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: 8 * scale)

                    Text(group?.totalDisplayAmount ?? "Rp 0")
                        .font(.system(size: 23 * scale, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                }
                .frame(height: 35 * scale)

                HStack(spacing: 15 * scale) {
                    BillList(bills: group?.bills ?? [], scale: scale)

                    VStack(spacing: 8 * scale) {
                        Link(destination: addBillURL(for: group?.id)) {
                            WidgetActionCapsule(
                                title: "Add Bill",
                                style: .orange,
                                height: 38 * scale,
                                fontSize: 19 * scale
                            )
                        }
                        .disabled(group == nil)

                        Button(intent: CopyChecklistIntent(groupID: group?.id)) {
                            WidgetActionCapsule(
                                title: "Copy List",
                                style: .grey,
                                height: 38 * scale,
                                fontSize: 19 * scale
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(group == nil)
                    }
                    .frame(width: 137 * scale)
                }
                .padding(.horizontal, 12 * scale)
                .padding(.vertical, 8 * scale)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 22 * scale)
                        .fill(Color.black.opacity(0.10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 22 * scale)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        }
                }
            }
            .padding(.horizontal, 14 * scale)
            .padding(.vertical, 13 * scale)
        }
    }
}
