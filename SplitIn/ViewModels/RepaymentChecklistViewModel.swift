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
        let settlements = group.settlements
        
        // Kondisi 1: Jika belum ada perhitungan sama sekali
        if settlements.isEmpty {
            // Kondisi 1.1: Cek apakah member group sudah ada atau belum
            if group.members.isEmpty {
                resultText = "*[📝 \(group.name)]* \n\n📣 Grup pengeluaran bersama telah dibuat. Siapkan nota kalian untuk dihitung bareng ya!"
            }
            // Kondisi 2: Sudah ada anggota tapi belum ada nominal transaksi
            else {
                resultText = "*[📝 \(group.name)]*\n\n**Daftar Anggota Terdaftar:**\n"
                for member in group.members {
                    resultText += "👥 *\(member.person.name)*\n"
                }
                resultText += "\n⏳ Semua anggota sudah masuk daftar. Silakan melakukan input perhitungan bill!"
            }
            
            UIPasteboard.general.string = resultText
            triggerHapticFeedback()
            
            print("LOG HASIL COPY:\n\(resultText)") 
        }
        // Kondisi 3: rekap lengkap
        else {
            resultText = "*\(group.name)]*\n\n"
            
            // Kelompokkan settlement berdasarkan penagih (fromMember) yang diambil dari ID GroupMember
            let groupedByDebtor = Dictionary(grouping: settlements, by: { $0.fromMember.id })
            
            for (_, memberSettlements) in groupedByDebtor {
                // Ambil nama pengirim (debtor/penagih) dari Settlement -> Person (fromMember -> person -> name)
                guard let debtorName = memberSettlements.first?.fromMember.person.name else { continue }
                resultText += "👤 *\(debtorName)*\n"
                
                for settlement in memberSettlements {
                    let creditorName = settlement.toMember.person.name
                    let formattedAmount = formatToRupiah(settlement.amount)
                    
                    // Format: pay to theo: Rp 130.000
                    resultText += "Bayar ke \(creditorName): *\(formattedAmount)*\n"
                }
                resultText += "\n"
            }
        }
    }
    
    @MainActor
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // format Rp desimal (cth: 15.000)
    private func formatToRupiah(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
            
        // Ubah Decimal menjadi NSDecimalNumber agar bisa diformat oleh NumberFormatter
        let formattedNumber = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "Rp\(formattedNumber)"
    }
    
    
    
}
