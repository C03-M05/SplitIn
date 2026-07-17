//
//  RepaymentChecklistViewModel.swift
//  SplitIn
//
//  Created by Sherin Alvinia Yonatan on 14/07/26.
//

import Foundation
import UIKit
import SwiftUI
import SwiftData
import Combine

class RepaymentChecklistViewModel: ObservableObject {
    private let group: Group
        
    init(group: Group) {
        self.group = group
    }
        
    // Function utama untuk copy checklist ke clipboard
    @MainActor
    func CopyChecklisttoClipboard() {
        var resultText = ""
        let sheet = group.balanceSheet()
        
        // Kondisi 1: Jika grup belum memiliki anggota sama sekali
        if group.members.isEmpty {
            resultText = "*[📝 \(group.name)]* \n\n📣 Grup pengeluaran bersama telah dibuat. Siapkan nota kalian untuk dihitung bareng ya!"
            
            UIPasteboard.general.string = resultText
            triggerHapticFeedback()
            print("LOG HASIL COPY (GRUP KOSONG):\n\(resultText)")
            return
        }
        
        // Cek udah ada kalkulasi atau masih kosong
        let hasTransactions = group.members.contains { member in
            if let balance = sheet[member.id] {
                return !balance.payTo.isEmpty || !balance.collectFrom.isEmpty
            }
            return false
        }
        
        // Kondisi 2: Sudah ada anggota tapi belum ada tagihan/bill yang diinput
        if !hasTransactions {
            resultText = "*[📝 \(group.name)]*\n\n**Daftar Anggota Terdaftar:**\n"
            for member in group.members {
                resultText += "👥 *\(member.person.name)*\n"
            }
            resultText += "\n⏳ Semua anggota sudah masuk daftar. Silakan melakukan input perhitungan bill!"
            
            UIPasteboard.general.string = resultText
            triggerHapticFeedback()
            print("LOG HASIL COPY (BELUM ADA BILL):\n\(resultText)")
            return
        }
        
        // Kondisi 3: sudah ada semua
        resultText = "*[\(group.name)]*\n\n"
        
        for member in group.members {
            // Member ada utang
            if let memberBalance = sheet[member.id], !memberBalance.payTo.isEmpty {
                resultText += "👤 *\(member.person.name)*\n"
                
                for entry in memberBalance.payTo {
                    // Mencari nama penerima dana berdasarkan UUID counterparty
                    if let creditor = group.members.first(where: { $0.id == entry.counterpartyMemberID }) {
                        let formattedAmount = formatToRupiah(entry.amount)
                        // Format send to group chat
                        resultText += "pay to \(creditor.person.name.lowercased()): *\(formattedAmount)*\n"
                    }
                }
                resultText += "\n"
            }
        }

        let cleanedText = resultText.trimmingCharacters(in: .whitespacesAndNewlines)
        UIPasteboard.general.string = cleanedText
        triggerHapticFeedback()
        
        // Cetak log ke konsol Xcode untuk mempermudah pengecekan developer
        print("LOG HASIL COPY (SUKSES TERCANGKOP):\n\(cleanedText)")
    }
    
    // MARK: - PDF

    @MainActor
    func generateAndSharePDF() {
        let pdfWidth: CGFloat = 390
        let cardHeight: CGFloat = 260
        let memberCount = group.members.count
        let pdfHeight: CGFloat = CGFloat(memberCount) * (cardHeight + 16) + 40

        let content = GroupSplitPDFView(group: group)
        let renderer = ImageRenderer(content: content.frame(width: pdfWidth, height: pdfHeight))
        renderer.scale = 2

        let fileName = "\(group.name) Split.pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        renderer.render { size, draw in
            var box = CGRect(origin: .zero, size: size)
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            pdfContext.beginPDFPage(nil)
            draw(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }

        guard let topVC = topMostViewController() else { return }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = topVC.view
        topVC.present(activityVC, animated: true)

        triggerHapticFeedback()
    }

    private func topMostViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let root = window.rootViewController else { return nil }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }

    @MainActor
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Mengubah tipe data Decimal menjadi format Rupiah rapi (cth: Rp 15.000)
    private func formatToRupiah(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
            
        let formattedNumber = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "Rp \(formattedNumber)"
    }
}
