//
//  TopNavigationBar.swift
//  SplitIn
//
//  Created by Miranda Utami on 14/07/26.
//

import SwiftUI

struct TopNavigationBar: View {
    
    let title: String
    let isComplete: Bool
    var onCancel: () -> Void
    var onSave: () -> Void
    
    var body: some View {
        HStack {
            
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .bold()
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray4))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            // Button save
            Button(action: { if isComplete { onSave() } }) {
                Image(systemName: "checkmark")
                    .bold()
                    .foregroundColor(isComplete ? .white : .primary)
                    .frame(width: 36, height: 36)
                    .background(isComplete ? Color.orange : Color(.systemGray4))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
    }
}

//#Preview {
//    TopNavigationBar(title: "Create Bill", isComplete: true, onCancel: {}, onSave: {})
//        .preferredColorScheme(.dark)
//}
