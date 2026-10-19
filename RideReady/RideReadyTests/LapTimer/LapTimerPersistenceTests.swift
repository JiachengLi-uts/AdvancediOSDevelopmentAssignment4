import XCTest
@testable import RideReady

final class LapTimerPersistenceTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: UserDefaultsRideReadyStore!

    override func setUpWithError() throws {
        suiteName = "RideReadyTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = UserDefaultsRideReadyStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        suiteName = nil
    }

    func test_tracksAndSessions_areEmpty_onFirstLaunch() {
        XCTAssertTrue(store.tracks().isEmpty)
        XCTAssertTrue(store.sessions().isEmpty)
    }

    func test_registeringATrack_isSavedInTheRideReadyStore() throws {
        let useCase = RegisterTrackUseCase(trackStore: RideReadyTrackStore(store: store))

        try useCase.execute(name: "Eastern Creek", location: "Sydney", lengthMeters: 3930, notes: "")

        XCTAssertEqual(store.tracks().map(\.name), ["Eastern Creek"])
        XCTAssertEqual(store.tracks().first?.lengthMeters, 3930)
    }

    func test_recordingASession_isSavedWithItsLaps() throws {
        store.save(.yamahaMT07())
        let track = try RegisterTrackUseCase(trackStore: RideReadyTrackStore(store: store))
            .execute(name: "Eastern Creek", location: "", lengthMeters: nil, notes: "")
        let useCase = RecordTrackDaySessionUseCase(
            vehicleStore: RideReadyVehicleStore(store: store),
            trackStore: RideReadyTrackStore(store: store),
            sessionStore: RideReadySessionStore(store: store)
        )

        try useCase.execute(
            vehicleID: Vehicle.rideReadyMotorcycleID,
            trackID: track.id,
            date: Date(timeIntervalSinceNow: -60),
            weather: .damp,
            trackCondition: "Cool",
            setupNotes: "Softer rear",
            laps: [Lap(lapNumber: 1, time: 101.5), Lap(lapNumber: 2, time: 100.25)]
        )

        let saved = try XCTUnwrap(store.sessions().first)
        XCTAssertEqual(saved.laps.map(\.time), [101.5, 100.25])
        XCTAssertEqual(saved.weather, .damp)
        XCTAssertEqual(saved.setupNotes, "Softer rear")
        XCTAssertEqual(saved.vehicleID, Vehicle.rideReadyMotorcycleID)
    }

    func test_lapTimerData_doesNotDisturbBikeData() {
        store.save(.yamahaMT07())

        store.saveTracks([Track(name: "Phillip Island")])

        XCTAssertEqual(store.motorcycle()?.name, "Yamaha MT-07")
    }
}
