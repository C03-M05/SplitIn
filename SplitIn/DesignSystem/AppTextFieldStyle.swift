//
//  AppTextFieldStyle.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import SwiftUI

struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.bodyText)
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.cardBackground)
            )
    }
}

extension TextFieldStyle where Self == AppTextFieldStyle {
    static var app: AppTextFieldStyle { AppTextFieldStyle() }
}

#Preview {
    VStack(spacing: 12) {
        TextField("group name", text: .constant(""))
            .textFieldStyle(.app)

        TextField("bill name", text: .constant("lunch @tanjungapi"))
            .textFieldStyle(.app)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}
