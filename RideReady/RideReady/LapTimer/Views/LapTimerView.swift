//
//  LapTimerView.swift
//

import SwiftUI

struct LapTimerView: View {
    @StateObject private var dataStore: DataStore
    @State private var selectedTab: MainTab = .dashboard
    @State private var showingNewSession = false

    private let onExit: () -> Void

    init(store: RideReadyStoring, onExit: @escaping () -> Void = {}) {
        self.onExit = onExit
        _dataStore = StateObject(wrappedValue: DataStore(rideReadyStore: store))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.screenBackground.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .tracks:
                    TracksView()
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 66)
            }

            LapTimerTabBar(selectedTab: $selectedTab) {
                showingNewSession = true
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .environment(\.exitLapTimer, onExit)
        .onAppear { dataStore.reloadVehicles() }
        .sheet(isPresented: $showingNewSession) {
            NewSessionView()
        }
        // Outermost, so the sheet (presented from this view) receives the store too.
        .environmentObject(dataStore)
    }
}

#Preview {
    let store = UserDefaultsRideReadyStore()
    if store.motorcycle() == nil {
        store.save(.yamahaMT07())
    }
    return LapTimerView(store: store)
}
