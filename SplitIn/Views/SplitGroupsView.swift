//
//  SplitGroupsView.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 14/07/26.
//

import SwiftUI

struct SplitGroupsView: View {
    // Membuat ukuran tombol mengikuti pengaturan Dynamic Type.
    @ScaledMetric(relativeTo: .title2)
    private var addButtonSize: CGFloat = 56

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(alignment: .center, spacing: 0) {
                Text("Your Split Groups")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)

                Spacer()

                Text("Add group")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)

                Spacer()
            }

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Button {
                        // MARK: Buka halaman untuk menambahkan grup
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(
                                width: addButtonSize,
                                height: addButtonSize
                            )
                            .contentShape(Circle())
                    }
                    .buttonStyle(.glass(.regular.tint(.orange)))
                    .buttonBorderShape(.circle)
                    .tint(.orange)

                    .accessibilityInputLabels([
                        "Add group",
                        "Add",
                        "New group"
                    ])

                    .padding(.trailing, 24)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview("Default") {
    SplitGroupsView()
}

//#Preview("Large Accessibility Text") {
//    SplitGroupsView()
//        .dynamicTypeSize(.accessibility5)
//}

//#Preview("Dark Mode") {
//    SplitGroupsView()
//        .preferredColorScheme(.dark)
//}
