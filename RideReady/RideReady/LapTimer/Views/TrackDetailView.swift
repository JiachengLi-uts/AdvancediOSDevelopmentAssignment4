//
//  TrackDetailView.swift
//

import SwiftUI

struct TrackDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    let track: Track
    @State private var showingEdit = false

    private var trackSessions: [Session] {
        dataStore.sessionsForTrack(track.id)
    }

    private var bestLap: Lap? {
        trackSessions.compactMap { $0.fastestLap }.min { $0.time < $1.time }
    }

    private var bestSession: Session? {
        guard let bestLap else { return nil }
        return trackSessions.first { session in
            session.laps.contains { $0.id == bestLap.id }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "Circuit Info")
                    VStack(spacing: 0) {
                        if !track.location.isEmpty {
                            StatRow(label: "Location", value: track.location)
                            CardDivider()
                        }
                        StatRow(label: "Length", value: track.formattedLength ?? "Unknown")
                    }
                    .padding(.horizontal, 14)
                    .cardStyle()

                    if !track.notes.isEmpty {
                        Text(track.notes)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                            .padding(.top, 2)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Session History")

                    if trackSessions.isEmpty {
                        Text("No sessions at this track yet")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.secondary)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(trackSessions) { session in
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
        .navigationTitle(track.name)
        .navigationDestination(for: Session.self) { session in
            LapStatisticsView(session: session)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditTrackView(trackToEdit: track)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Color.accentColor))

            if let bestLap {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PERSONAL BEST")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                    Text(bestLap.time.formattedTime)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.primary)
                    if let bestSession, let vehicle = dataStore.vehicle(for: bestSession.vehicleID) {
                        Text("on \(vehicle.name)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                    }
                }
            } else {
                Text("No laps recorded at this track yet")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient.heroCard)
        )
    }
}
