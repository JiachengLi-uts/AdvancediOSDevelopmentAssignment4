//
//  RecordTrackDaySessionUseCaseTests.swift
//

import Testing
import Foundation
@testable import RideReady

struct RecordTrackDaySessionUseCaseTests {

    private func seededVehicleStore() -> (store: InMemoryStore<Vehicle>, vehicleID: UUID) {
        let vehicle = Vehicle(name: "Track Bike", type: .motorcycle, make: "Yamaha", model: "R6")
        return (InMemoryStore(items: [vehicle]), vehicle.id)
    }

    private func seededTrackStore() -> (store: InMemoryStore<Track>, trackID: UUID) {
        let track = Track(name: "Eastern Creek", location: "Sydney, NSW")
        return (InMemoryStore(items: [track]), track.id)
    }

    @Test func recordSession_succeeds_withRegisteredVehicleAndTrackAndValidLaps() throws {
        let (vehicleStore, vehicleID) = seededVehicleStore()
        let (trackStore, trackID) = seededTrackStore()
        let sessionStore = InMemoryStore<Session>()
        let useCase = RecordTrackDaySessionUseCase(vehicleStore: vehicleStore, trackStore: trackStore, sessionStore: sessionStore)

        let laps = [Lap(lapNumber: 1, time: 102.311), Lap(lapNumber: 2, time: 101.874)]
        let session = try useCase.execute(
            vehicleID: vehicleID,
            trackID: trackID,
            date: Date(),
            weather: .dry,
            trackCondition: "",
            setupNotes: "",
            laps: laps
        )

        #expect(session.laps.count == 2)
        #expect(session.fastestLap?.time == 101.874)
        #expect(sessionStore.loadAll().count == 1)
    }

    @Test func recordSession_fails_whenVehicleIsNotRegistered() {
        let vehicleStore = InMemoryStore<Vehicle>() 
        let (trackStore, trackID) = seededTrackStore()
        let sessionStore = InMemoryStore<Session>()
        let useCase = RecordTrackDaySessionUseCase(vehicleStore: vehicleStore, trackStore: trackStore, sessionStore: sessionStore)

        do {
            _ = try useCase.execute(
                vehicleID: UUID(),
                trackID: trackID,
                date: Date(),
                weather: .dry,
                trackCondition: "",
                setupNotes: "",
                laps: [Lap(lapNumber: 1, time: 100)]
            )
            Issue.record("Expected TrackDaySessionError.vehicleNotRegistered to be thrown")
        } catch TrackDaySessionError.vehicleNotRegistered {
            // expected
        } catch {
            Issue.record("Expected .vehicleNotRegistered but got \(error)")
        }
    }

    @Test func recordSession_fails_whenTrackIsNotRegistered() {
        let (vehicleStore, vehicleID) = seededVehicleStore()
        let trackStore = InMemoryStore<Track>() 
        let sessionStore = InMemoryStore<Session>()
        let useCase = RecordTrackDaySessionUseCase(vehicleStore: vehicleStore, trackStore: trackStore, sessionStore: sessionStore)

        do {
            _ = try useCase.execute(
                vehicleID: vehicleID,
                trackID: UUID(),
                date: Date(),
                weather: .dry,
                trackCondition: "",
                setupNotes: "",
                laps: [Lap(lapNumber: 1, time: 100)]
            )
            Issue.record("Expected TrackDaySessionError.trackNotRegistered to be thrown")
        } catch TrackDaySessionError.trackNotRegistered {
            // expected
        } catch {
            Issue.record("Expected .trackNotRegistered but got \(error)")
        }
    }

    @Test func recordSession_fails_whenSessionDateIsInTheFuture() {
        let (vehicleStore, vehicleID) = seededVehicleStore()
        let (trackStore, trackID) = seededTrackStore()
        let sessionStore = InMemoryStore<Session>()
        let referenceNow = Date(timeIntervalSince1970: 1_700_000_000)
        let useCase = RecordTrackDaySessionUseCase(
            vehicleStore: vehicleStore,
            trackStore: trackStore,
            sessionStore: sessionStore,
            now: { referenceNow }
        )
        let tomorrow = referenceNow.addingTimeInterval(86_400)

        do {
            _ = try useCase.execute(
                vehicleID: vehicleID,
                trackID: trackID,
                date: tomorrow,
                weather: .dry,
                trackCondition: "",
                setupNotes: "",
                laps: [Lap(lapNumber: 1, time: 100)]
            )
            Issue.record("Expected TrackDaySessionError.sessionDateInFuture to be thrown")
        } catch TrackDaySessionError.sessionDateInFuture {
            // expected
        } catch {
            Issue.record("Expected .sessionDateInFuture but got \(error)")
        }
    }

    @Test func recordSession_fails_whenNoLapsAreRecorded() {
        let (vehicleStore, vehicleID) = seededVehicleStore()
        let (trackStore, trackID) = seededTrackStore()
        let sessionStore = InMemoryStore<Session>()
        let useCase = RecordTrackDaySessionUseCase(vehicleStore: vehicleStore, trackStore: trackStore, sessionStore: sessionStore)

        do {
            _ = try useCase.execute(
                vehicleID: vehicleID,
                trackID: trackID,
                date: Date(),
                weather: .dry,
                trackCondition: "",
                setupNotes: "",
                laps: []
            )
            Issue.record("Expected TrackDaySessionError.noLapsRecorded to be thrown for an empty laps array")
        } catch TrackDaySessionError.noLapsRecorded {
            // expected
        } catch {
            Issue.record("Expected .noLapsRecorded but got \(error)")
        }
    }

    @Test func recordSession_fails_whenALapTimeIsZeroOrNegative() {
        let (vehicleStore, vehicleID) = seededVehicleStore()
        let (trackStore, trackID) = seededTrackStore()
        let sessionStore = InMemoryStore<Session>()
        let useCase = RecordTrackDaySessionUseCase(vehicleStore: vehicleStore, trackStore: trackStore, sessionStore: sessionStore)

        do {
            _ = try useCase.execute(
                vehicleID: vehicleID,
                trackID: trackID,
                date: Date(),
                weather: .dry,
                trackCondition: "",
                setupNotes: "",
                laps: [Lap(lapNumber: 1, time: 0)]
            )
            Issue.record("Expected TrackDaySessionError.invalidLapTime to be thrown for a zero-second lap")
        } catch TrackDaySessionError.invalidLapTime {
            // expected
        } catch {
            Issue.record("Expected .invalidLapTime but got \(error)")
        }
    }
}
