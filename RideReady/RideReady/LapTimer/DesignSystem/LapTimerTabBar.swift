//
//  LapTimerTabBar.swift
//

import SwiftUI

enum MainTab {
    case dashboard, tracks
}

struct LapTimerTabBar: View {
    @Binding var selectedTab: MainTab
    var onRecordSession: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.dashboard, icon: "speedometer", label: "Dashboard")
            tabButton(nil, icon: "stopwatch.fill", label: "Add Session")
            tabButton(.tracks, icon: "flag.checkered", label: "Tracks")
        }
        .padding(.horizontal, 12)
        .padding(.top, 14)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                .fill(Color.cardFill)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(_ tab: MainTab?, icon: String, label: String) -> some View {
        Button {
            if let tab {
                selectedTab = tab
            } else {
                onRecordSession()
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(tab != nil && selectedTab == tab ? Color.accentColor : Color.secondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab == nil ? "Add New Session" : label)
    }
}
