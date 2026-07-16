//
//  Colors.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import SwiftUI

extension Color {
    /// Background utama app — systemGray6
    static let appBackground = Color(.systemGray6)

    /// Card / row container — systemGray5, sedikit terangkat dari background
    static let cardBackground = Color(.systemGray5)

    /// Avatar circle saat tidak terpilih
    static let avatarBackground = Color(.systemGray4)

    /// Accent color app — dipakai untuk tombol utama, avatar terpilih, FAB
    static let accentOrange = Color.orange

    /// Delete button
    static let destructiveRed = Color.red

    /// Text utama — otomatis putih di dark mode, hitam di light mode
    static let textPrimary = Color.primary

    /// Text sekunder — tanggal, caption, label non-aktif
    static let textSecondary = Color.secondary
    
    /// Avatar circle saat ter-tag/terpilih — kontras tinggi (putih di dark, hitam di light)
    static let avatarSelected = Color.primary

    /// Inisial di dalam avatar yang terpilih — kebalikan dari avatarSelected
    static let avatarSelectedText = Color(.systemBackground)
}
