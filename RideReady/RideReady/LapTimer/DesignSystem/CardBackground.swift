//
//  CardBackground.swift
//

import SwiftUI

private struct CardBackgroundStyle: ViewModifier {
    var cornerRadius: CGFloat
    var fill: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 18, fill: Color = .cardFill) -> some View {
        modifier(CardBackgroundStyle(cornerRadius: cornerRadius, fill: fill))
    }
}
