import Foundation

/// Starts a ride so RideReady can time it and remind the rider to take breaks.
///
/// Business Rules:
/// - Only one ride can be in progress.
/// - The bike must have passed a pre-ride check today.
struct StartRideUseCase {
    let store: RideReadyStoring
    let now: () -> Date

    init(store: RideReadyStoring, now: @escaping () -> Date = Date.init) {
        self.store = store
        self.now = now
    }

    func start() throws -> Ride {
        guard store.activeRide() == nil else {
            throw RideError.rideInProgress
        }
        let startedAt = now()
        guard store.activeInspection() == nil,
              let latest = store.completedInspections().first,
              latest.readiness == .readyToRide,
              let checkedAt = latest.completedAt,
              Calendar.current.isDate(checkedAt, inSameDayAs: startedAt) else {
            throw RideError.bikeNotRideReady
        }
        let ride = Ride(id: UUID(), startedAt: startedAt, endedAt: nil, stops: [], remindAgainAt: nil)
        store.save(ride)
        return ride
    }
}
