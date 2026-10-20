//
//  TracksView.swift
//

import SwiftUI

struct TracksView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showingRegisterTrack = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if dataStore.tracks.isEmpty {
                        EmptyStateView(
                            title: "No Tracks",
                            systemImage: "flag.checkered",
                            message: "Register a circuit to start logging sessions there."
                        )
                    } else {
                        VStack(spacing: 10) {
                            ForEach(dataStore.tracks) { track in
                                NavigationLink(value: track) {
                                    TrackRow(track: track)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        dataStore.deleteTrack(track)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
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
            .navigationDestination(for: Track.self) { track in
                TrackDetailView(track: track)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingRegisterTrack) {
                AddEditTrackView()
            }
        }
    }

    private var header: some View {
        HStack {
            ExitLapTimerButton()
            Text("Tracks")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(Color.primary)
            Spacer()
            Button {
                showingRegisterTrack = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.accentColor))
            }
            .accessibilityLabel("Register Track")
        }
    }
}

private struct TrackRow: View {
    @EnvironmentObject var dataStore: DataStore
    let track: Track

    private var personalBest: Lap? {
        dataStore.personalBest(atTrack: track.id)
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.cardFillElevated))

            VStack(alignment: .leading, spacing: 3) {
                Text(track.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                if !track.location.isEmpty {
                    Text(track.location)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer()

            if let personalBest {
                Text(personalBest.time.formattedTime)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentColor)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(14)
        .cardStyle()
    }
}

#Preview {
    TracksView()
        .environmentObject(DataStore(rideReadyStore: UserDefaultsRideReadyStore()))
}
