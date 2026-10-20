//
//  DataStore.swift
//  RideReady
//

import Foundation
import Combine

@MainActor
final class DataStore: ObservableObject {
    /// The rider's RideReady motorcycle. There is no separate list of bikes for
    /// the lap timer: this is read from the same store as the pre-ride check.
    @Published private(set) var vehicles: [Vehicle] = []
    @Published private(set) var tracks: [Track] = []
    @Published private(set) var sessions: [Session] = []

    private let vehicleStore: RideReadyVehicleStore
    private let trackStore: RideReadyTrackStore
    private let sessionStore: RideReadySessionStore

    init(rideReadyStore: RideReadyStoring) {
        vehicleStore = RideReadyVehicleStore(store: rideReadyStore)
        trackStore = RideReadyTrackStore(store: rideReadyStore)
        sessionStore = RideReadySessionStore(store: rideReadyStore)
        loadAll()
    }

    func loadAll() {
        reloadVehicles()
        tracks = trackStore.loadAll().sorted { $0.name < $1.name }
        sessions = sessionStore.loadAll().sorted { $0.date > $1.date }
    }

    /// Picks up edits made to the bike in the Bike tab.
    func reloadVehicles() {
        vehicles = vehicleStore.loadAll().sorted { $0.name < $1.name }
    }

    // MARK: - Track: register (Use Case), update/delete (simple CRUD)

    @discardableResult
    func registerTrack(
        name: String,
        location: String,
        lengthMeters: Double?,
        notes: String
    ) throws -> Track {
        let useCase = RegisterTrackUseCase(trackStore: trackStore)
        let track = try useCase.execute(name: name, location: location, lengthMeters: lengthMeters, notes: notes)
        tracks = trackStore.loadAll().sorted { $0.name < $1.name }
        return track
    }

    func updateTrack(_ track: Track) {
        var allTracks = trackStore.loadAll()
        guard let index = allTracks.firstIndex(where: { $0.id == track.id }) else { return }
        allTracks[index] = track
        trackStore.save(allTracks)
        tracks = allTracks.sorted { $0.name < $1.name }
    }

    func deleteTrack(_ track: Track) {
        let remaining = trackStore.loadAll().filter { $0.id != track.id }
        trackStore.save(remaining)
        tracks = remaining.sorted { $0.name < $1.name }
    }

    // MARK: - Session: record (Use Case), update/delete (simple CRUD)

    @discardableResult
    func recordSession(
        vehicleID: UUID,
        trackID: UUID,
        date: Date,
        weather: WeatherCondition,
        trackCondition: String,
        setupNotes: String,
        laps: [Lap]
    ) throws -> Session {
        let useCase = RecordTrackDaySessionUseCase(vehicleStore: vehicleStore, trackStore: trackStore, sessionStore: sessionStore)
        let session = try useCase.execute(
            vehicleID: vehicleID,
            trackID: trackID,
            date: date,
            weather: weather,
            trackCondition: trackCondition,
            setupNotes: setupNotes,
            laps: laps
        )
        sessions = sessionStore.loadAll().sorted { $0.date > $1.date }
        return session
    }

    func updateSession(_ session: Session) {
        var allSessions = sessionStore.loadAll()
        guard let index = allSessions.firstIndex(where: { $0.id == session.id }) else { return }
        allSessions[index] = session
        sessionStore.save(allSessions)
        sessions = allSessions.sorted { $0.date > $1.date }
    }

    func deleteSession(_ session: Session) {
        let remaining = sessionStore.loadAll().filter { $0.id != session.id }
        sessionStore.save(remaining)
        sessions = remaining.sorted { $0.date > $1.date }
    }

    // MARK: - Lookups

    func vehicle(for id: UUID) -> Vehicle? {
        vehicles.first { $0.id == id }
    }

    func track(for id: UUID) -> Track? {
        tracks.first { $0.id == id }
    }

    func sessionsForVehicle(_ vehicleID: UUID) -> [Session] {
        sessions.filter { $0.vehicleID == vehicleID }
    }

    func sessionsForTrack(_ trackID: UUID) -> [Session] {
        sessions.filter { $0.trackID == trackID }
    }

    var overallPersonalBest: (session: Session, lap: Lap)? {
        var best: (session: Session, lap: Lap)?
        for session in sessions {
            guard let fastest = session.fastestLap else { continue }
            if best == nil || fastest.time < best!.lap.time {
                best = (session, fastest)
            }
        }
        return best
    }

    func personalBest(atTrack trackID: UUID, vehicleID: UUID? = nil) -> Lap? {
        sessions
            .filter { $0.trackID == trackID && (vehicleID == nil || $0.vehicleID == vehicleID) }
            .compactMap { $0.fastestLap }
            .min { $0.time < $1.time }
    }
}
