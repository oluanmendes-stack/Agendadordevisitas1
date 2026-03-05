// DesignSystem.swift
// Tokens visuais que espelham o protótipo React

import SwiftUI

// MARK: - Cores
extension Color {
    static let appBackground    = Color(red: 0.949, green: 0.949, blue: 0.969) // #F2F2F7
    static let cardBackground   = Color.white
    static let cardHoje         = Color(red: 1.0,   green: 0.969, blue: 0.941) // #FFF7F0
    static let cardPassado      = Color(red: 0.976, green: 0.976, blue: 0.976) // #F9F9F9

    static let brandBlue        = Color(red: 0.0,   green: 0.478, blue: 1.0)   // #007AFF
    static let brandOrange      = Color(red: 1.0,   green: 0.420, blue: 0.0)   // #FF6B00
    static let brandGreen       = Color(red: 0.204, green: 0.780, blue: 0.349) // #34C759
    static let brandRed         = Color(red: 1.0,   green: 0.231, blue: 0.188) // #FF3B30
    static let brandYellow      = Color(red: 1.0,   green: 0.584, blue: 0.0)   // #FF9500

    static let label            = Color(red: 0.110, green: 0.110, blue: 0.118) // #1C1C1E
    static let secondaryLabel   = Color(red: 0.557, green: 0.557, blue: 0.576) // #8E8E93
    static let tertiaryLabel    = Color(red: 0.922, green: 0.922, blue: 0.961) // #EBEBEB
    static let separator        = Color(red: 0.941, green: 0.941, blue: 0.941) // #F0F0F0
    static let inputBackground  = Color(red: 0.980, green: 0.980, blue: 0.980) // #FAFAFA
    static let pillBackground   = Color(red: 0.949, green: 0.949, blue: 0.969) // #F2F2F7

    static let borderHoje       = Color(red: 1.0, green: 0.420, blue: 0.0).opacity(0.35)
    static let borderDefault    = Color(red: 0.922, green: 0.922, blue: 0.922) // #EBEBEB
}

// MARK: - Tipografia
extension Font {
    static let navTitle    = Font.system(size: 28, weight: .heavy, design: .rounded)
    static let navSubtitle = Font.system(size: 13, weight: .regular)
    static let cardTitle   = Font.system(size: 15, weight: .bold)
    static let cardSub     = Font.system(size: 13, weight: .regular)
    static let infoLabel   = Font.system(size: 13, weight: .regular)
    static let priceBadge  = Font.system(size: 14, weight: .bold)
    static let actionBtn   = Font.system(size: 12, weight: .semibold)
    static let sectionTag  = Font.system(size: 11, weight: .bold)
    static let filterPill  = Font.system(size: 13, weight: .medium)
    static let badge       = Font.system(size: 10, weight: .heavy)
}

// MARK: - Raios de cantos
enum Radius {
    static let card:   CGFloat = 18
    static let action: CGFloat = 10
    static let input:  CGFloat = 10
    static let sheet:  CGFloat = 22
    static let pill:   CGFloat = 20
    static let icon:   CGFloat = 12
    static let toggle: CGFloat = 15
}

// MARK: - Sombras
struct CardShadow: ViewModifier {
    var isHoje: Bool
    func body(content: Content) -> some View {
        content.shadow(
            color: isHoje
                ? Color.brandOrange.opacity(0.10)
                : Color.black.opacity(0.05),
            radius: isHoje ? 8 : 4,
            x: 0, y: 2
        )
    }
}

extension View {
    func cardShadow(isHoje: Bool = false) -> some View {
        modifier(CardShadow(isHoje: isHoje))
    }
}
