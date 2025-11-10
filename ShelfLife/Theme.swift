//
//  Theme.swift
//  ShelfLife
//
//  Created by Garry Moyer on 4/7/25.
//

import SwiftUI

struct AppColors {
    static let primaryGreen = Color(hex: "#A4D96C")
    static let warningYellow = Color(hex: "#FDD85D")
    static let expiredRed = Color(hex: "#FF6B6B")
    static let accentOrange = Color(hex: "#FFA94D")
    static let deepTeal = Color(hex: "#2A9D8F")
    static let lightBackground = Color(hex: "#FFF9F1")
    static let tabHighlight = Color(hex: "#FFE17D")
}

struct AppFonts {
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let sectionHeader = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 18, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 14, weight: .medium, design: .rounded)
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: .whitespacesAndNewlines))
        var rgb: UInt64 = 0
        if scanner.scanString("#") != nil {
            scanner.scanHexInt64(&rgb)
        }
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
