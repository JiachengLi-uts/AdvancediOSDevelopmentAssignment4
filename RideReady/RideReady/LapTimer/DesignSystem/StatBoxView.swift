//
//  StatBoxView.swift
//

import SwiftUI

struct StatBoxView: View {
    let value: String
    let caption: String
    var accent: Color = .primary

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(caption)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .cardStyle(cornerRadius: 14, fill: .cardFillElevated)
    }
}

#Preview {
    HStack(spacing: 10) {
        StatBoxView(value: "1", caption: "Min")
        StatBoxView(value: "42", caption: "Sec")
        StatBoxView(value: "311", caption: "Ms")
    }
    .padding()
    .background(Color.screenBackground)
}
