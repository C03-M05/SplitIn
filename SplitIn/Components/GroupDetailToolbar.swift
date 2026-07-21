//
//  GroupDetailToolbar.swift
//  SplitIn
//

import SwiftUI

struct GroupDetailToolbar: ToolbarContent {
    @ObservedObject var viewModel: RepaymentChecklistViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button(action: {
                    viewModel.CopyChecklisttoClipboard()
                }) {
                    Label("Copy Checklist", systemImage: "doc.on.doc")
                }

                Button(action: {
                    viewModel.generateAndSharePDF()
                }) {
                    Label("Download PDF", systemImage: "arrow.down.doc")
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(!viewModel.hasBills)
            .accessibilityLabel("Share options")
            .accessibilityHint(
                viewModel.hasBills
                ? "Double tap to copy the split checklist or download a PDF"
                : "Add a bill first to share the split"
            )
        }
    }
}
