//
//  GroupDetailTopNavigationBar.swift
//  SplitIn
//
//  Created by Sherin Alvinia Yonatan on 15/07/26.
//

import SwiftUI
import SwiftData

struct GroupDetailTopNavigationBar: View {
    
    var onBack: () -> Void
    @ObservedObject var viewModel: RepaymentChecklistViewModel
    
    var body: some View {
        HStack {
            // 1. Tombol Back
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .bold()
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray4))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Kembali")
            .accessibilityHint("Kembali ke halaman utama grup")
            
            Spacer()
            
            // 2. Share Menu Button
            Menu {
                Button(action: {
                    viewModel.CopyChecklisttoClipboard()
                }) {
                    Label("Copy Checklist", systemImage: "doc.on.doc")
                }
                
                Button(action: {
                    // Download PDF (nanti)
                }) {
                    Label("Download PDF", systemImage: "arrow.down.doc")
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.orange)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Opsi Bagikan")
            .accessibilityHint("Ketuk dua kali untuk menyalin rekap tagihan atau mengunduh PDF")
            
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
    }
}

// Preview dari Seeder
#Preview {
    let container = Seeders.previewContainer()
    let context = container.mainContext
    
    let fetchDescriptor = FetchDescriptor<Group>()
    let groups = try! context.fetch(fetchDescriptor)
    let group = groups.first ?? Group(name: "Malang Trip")
    
    let vm = RepaymentChecklistViewModel(group: group)
    
    return GroupDetailTopNavigationBar(
        onBack: { print("Tombol Back Ditekan!") },
        viewModel: vm
    )
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
