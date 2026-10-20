//
//  Theme.swift
//


import SwiftUI
import UIKit

extension Color {
    static let screenBackground = Color(uiColor: .systemGroupedBackground)
    static let cardFill = Color(uiColor: .secondarySystemGroupedBackground)
    static let cardFillElevated = Color(uiColor: .tertiarySystemGroupedBackground)
    static let cardDivider = Color(uiColor: .separator)
}

extension LinearGradient {
    /// The tinted highlight card
    static let heroCard = LinearGradient(
        colors: [Color.accentColor.opacity(0.18), Color.accentColor.opacity(0.06)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
