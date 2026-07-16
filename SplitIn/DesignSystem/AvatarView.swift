//
//  AvatarView.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import SwiftUI

struct AvatarCircle: View {
    let name: String
    var isSelected: Bool = false
    var size: CGFloat = 44

    private var initial: String {
        name.trimmingCharacters(in: .whitespaces).first.map(String.init)?.uppercased() ?? "?"
    }

    var body: some View {
        Circle()
            .fill(isSelected ? Color.avatarSelected : Color.avatarBackground)
            .frame(width: size, height: size)
            .overlay(
                Text(initial)
                    .font(.avatarInitial)
                    .foregroundStyle(isSelected ? Color.avatarSelectedText : Color.textPrimary)
            )
    }
}

struct AvatarTag: View {
    let name: String
    var isSelected: Bool = false
    var size: CGFloat = 44
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: 6) {
                AvatarCircle(name: name, isSelected: isSelected, size: size)
                Text(name.lowercased())
                    .font(.captionText)
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }
}

struct AddAvatarButton: View {
    var size: CGFloat = 44
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Circle()
                    .strokeBorder(Color.textSecondary, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundStyle(Color.textSecondary)
                    )
                Text("add")
                    .font(.captionText)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Interactive Preview

private struct AvatarPreviewHarness: View {
    @State private var selected: Set<String> = ["sherin"]

    private let names = ["sherin", "miranda", "farhan", "axel", "theo"]

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                ForEach(names, id: \.self) { name in
                    AvatarTag(
                        name: name,
                        isSelected: selected.contains(name)
                    ) {
                        if selected.contains(name) {
                            selected.remove(name)
                        } else {
                            selected.insert(name)
                        }
                    }
                }
            }

            AddAvatarButton(onTap: {})

            Text("Tagged: \(selected.sorted().joined(separator: ", "))")
                .font(.captionText)
                .foregroundStyle(Color.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview("Dark") {
    AvatarPreviewHarness()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    AvatarPreviewHarness()
        .preferredColorScheme(.light)
}
