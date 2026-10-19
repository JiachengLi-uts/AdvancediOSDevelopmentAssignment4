//
//  DashboardView.swift
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    personalBestCard

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Recent Sessions")

                        if dataStore.sessions.isEmpty {
                            Text("No sessions yet. Tap the stopwatch below to record your first one.")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.secondary)
                                .padding(.vertical, 4)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(dataStore.sessions.prefix(5)) { session in
                                    NavigationLink(value: session) {
                                        SessionRow(session: session)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color.screenBackground.ignoresSafeArea())
            .navigationDestination(for: Session.self) { session in
                LapStatisticsView(session: session)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack {
            ExitLapTimerButton()
            VStack(alignment: .leading, spacing: 2) {
                Text("Lap Timer")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Color.primary)
                Text("Track your fastest laps")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Image(systemName: "flag.checkered.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(Color.accentColor)
        }
    }

    @ViewBuilder
    private var personalBestCard: some View {
        if let best = dataStore.overallPersonalBest {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PERSONAL BEST")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.accentColor)
                        Text("\(trackName(for: best.session)) — \(vehicleName(for: best.session))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.primary)
                    }
                    Spacer()
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.accentColor)
                }

                let components = best.lap.time.lapTimeComponents
                HStack(spacing: 10) {
                    StatBoxView(value: "\(components.minutes)", caption: "Min", accent: .accentColor)
                    StatBoxView(value: String(format: "%02d", components.seconds), caption: "Sec", accent: .accentColor)
                    StatBoxView(value: String(format: "%03d", components.milliseconds), caption: "Ms", accent: .accentColor)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient.heroCard)
            )
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("PERSONAL BEST")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                Text("No lap times recorded yet")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text("Tap the stopwatch below to record your first session.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient.heroCard)
            )
        }
    }

    private func trackName(for session: Session) -> String {
        dataStore.track(for: session.trackID)?.name ?? "Unknown Track"
    }

    private func vehicleName(for session: Session) -> String {
        dataStore.vehicle(for: session.vehicleID)?.name ?? "Unknown Vehicle"
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataStore(rideReadyStore: UserDefaultsRideReadyStore()))
}
