//
//  RepaymentChecklistViewModel.swift
//  SplitIn
//
//  Created by Sherin Alvinia Yonatan on 14/07/26.
//

import Foundation
import UIKit
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
