//
//  StatRow.swift
//

import SwiftUI

struct StatRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(valueColor)
        }
        .padding(.vertical, 10)
    }
}

struct CardDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.cardDivider)
            .frame(height: 1)
    }
}
