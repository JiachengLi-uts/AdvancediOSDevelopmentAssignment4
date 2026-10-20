import XCTest
@testable import RideReady

final class RideReadyVehicleStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: UserDefaultsRideReadyStore!
    private var vehicleStore: RideReadyVehicleStore!

    override func setUpWithError() throws {
        suiteName = "RideReadyTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = UserDefaultsRideReadyStore(defaults: defaults)
        vehicleStore = RideReadyVehicleStore(store: store)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        vehicleStore = nil
        suiteName = nil
    }

    func test_lapTimerVehicles_areEmpty_whenNoBikeIsSetUp() {
        XCTAssertTrue(vehicleStore.loadAll().isEmpty)
    }

    func test_lapTimerVehicles_areTheBikeTabMotorcycle() {
        store.save(.yamahaMT07())

        let vehicles = vehicleStore.loadAll()

        XCTAssertEqual(vehicles.count, 1)
        XCTAssertEqual(vehicles.first?.name, "Yamaha MT-07")
        XCTAssertEqual(vehicles.first?.type, .motorcycle)
        XCTAssertEqual(vehicles.first?.id, Vehicle.rideReadyMotorcycleID)
    }

    func test_renamingTheBike_keepsTheSameLapTimerVehicle() throws {
        store.save(.yamahaMT07())
        let before = try XCTUnwrap(vehicleStore.loadAll().first)

        _ = try SaveMotorcycleUseCase(store: store).save(
            Motorcycle(
                name: "Track MT-07",
                finalDrive: .chain,
                frontTyrePressurePSI: 36,
                rearTyrePressurePSI: 42,
                chainSlackMinMillimetres: 25,
                chainSlackMaxMillimetres: 35
            )
        )
        let after = try XCTUnwrap(vehicleStore.loadAll().first)

        XCTAssertEqual(after.id, before.id)
        XCTAssertEqual(after.name, "Track MT-07")
    }

    func test_savingThroughTheLapTimerStore_doesNotChangeTheBike() {
        store.save(.yamahaMT07())

        vehicleStore.save([Vehicle(name: "Another Bike", type: .motorcycle)])

        XCTAssertEqual(store.motorcycle()?.name, "Yamaha MT-07")
        XCTAssertEqual(vehicleStore.loadAll().map(\.name), ["Yamaha MT-07"])
    }

    func test_recordSession_usesTheSharedBike() throws {
        store.save(.yamahaMT07())
        let track = Track(name: "Eastern Creek")
        let sessionStore = InMemoryStore<Session>()
        let useCase = RecordTrackDaySessionUseCase(
            vehicleStore: vehicleStore,
            trackStore: InMemoryStore(items: [track]),
            sessionStore: sessionStore
        )

        let session = try useCase.execute(
            vehicleID: Vehicle.rideReadyMotorcycleID,
            trackID: track.id,
            date: Date(),
            weather: .dry,
            trackCondition: "",
            setupNotes: "",
            laps: [Lap(lapNumber: 1, time: 102.311)]
        )

        XCTAssertEqual(session.vehicleID, Vehicle.rideReadyMotorcycleID)
        XCTAssertEqual(sessionStore.loadAll().count, 1)
    }

    func test_recordSession_fails_whenNoBikeIsSetUp() {
        let track = Track(name: "Eastern Creek")
        let useCase = RecordTrackDaySessionUseCase(
            vehicleStore: vehicleStore,
            trackStore: InMemoryStore(items: [track]),
            sessionStore: InMemoryStore<Session>()
        )

        XCTAssertThrowsError(
            try useCase.execute(
                vehicleID: Vehicle.rideReadyMotorcycleID,
                trackID: track.id,
                date: Date(),
                weather: .dry,
                trackCondition: "",
                setupNotes: "",
                laps: [Lap(lapNumber: 1, time: 100)]
            )
        ) { error in
            XCTAssertEqual(
                error as? TrackDaySessionError,
                .vehicleNotRegistered(vehicleID: Vehicle.rideReadyMotorcycleID)
            )
        }
    }
}
