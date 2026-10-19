//
//  ExitLapTimerButton.swift
//

import SwiftUI

private struct ExitLapTimerKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var exitLapTimer: (() -> Void)? {
        get { self[ExitLapTimerKey.self] }
        set { self[ExitLapTimerKey.self] = newValue }
    }
}

struct ExitLapTimerButton: View {
    @Environment(\.exitLapTimer) private var exitLapTimer

    var body: some View {
        if let exitLapTimer {
            Button(action: exitLapTimer) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.cardFill))
            }
            .accessibilityLabel("Back to RideReady")
        }
    }
}
