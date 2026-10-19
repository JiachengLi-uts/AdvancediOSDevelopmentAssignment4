//
//  RegisterTrackUseCaseTests.swift
//

import Testing
import Foundation
@testable import RideReady

struct RegisterTrackUseCaseTests {

    @Test func registerTrack_succeeds_withValidDetails() throws {
        let store = InMemoryStore<Track>()
        let useCase = RegisterTrackUseCase(trackStore: store)

        let track = try useCase.execute(
            name: "Eastern Creek",
            location: "Sydney, NSW",
            lengthMeters: 3930,
            notes: ""
        )

        #expect(track.name == "Eastern Creek")
        #expect(store.loadAll().count == 1)
    }

    @Test func registerTrack_fails_whenNameIsBlank() {
        let store = InMemoryStore<Track>()
        let useCase = RegisterTrackUseCase(trackStore: store)

        do {
            _ = try useCase.execute(name: "  ", location: "", lengthMeters: nil, notes: "")
            Issue.record("Expected TrackRegistrationError.missingName to be thrown for a blank name")
        } catch TrackRegistrationError.missingName {
            // expected
        } catch {
            Issue.record("Expected .missingName but got \(error)")
        }
    }

    @Test func registerTrack_fails_whenNameIsDuplicate_caseInsensitive() throws {
        let store = InMemoryStore<Track>()
        let useCase = RegisterTrackUseCase(trackStore: store)
        try useCase.execute(name: "Eastern Creek", location: "", lengthMeters: nil, notes: "")

        do {
            _ = try useCase.execute(name: "eastern creek", location: "", lengthMeters: nil, notes: "")
            Issue.record("Expected TrackRegistrationError.duplicateName to be thrown for a case-insensitive name clash")
        } catch TrackRegistrationError.duplicateName {
            // expected
        } catch {
            Issue.record("Expected .duplicateName but got \(error)")
        }
    }

    @Test func registerTrack_fails_whenLengthIsZeroOrNegative() {
        let store = InMemoryStore<Track>()
        let useCase = RegisterTrackUseCase(trackStore: store)

        do {
            _ = try useCase.execute(name: "Practice Loop", location: "", lengthMeters: 0, notes: "")
            Issue.record("Expected TrackRegistrationError.invalidLength to be thrown for a zero-length track")
        } catch TrackRegistrationError.invalidLength {
            // expected
        } catch {
            Issue.record("Expected .invalidLength but got \(error)")
        }
    }
}
