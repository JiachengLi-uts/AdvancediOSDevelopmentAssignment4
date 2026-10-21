import Foundation

/// Lists the journal entries logged during a ride, oldest first.
struct LoadRideJournalUseCase {
    let journal: RideJournalRepository

    func entries(forRide rideID: UUID) throws -> [JournalEntry] {
        do {
            return try journal.entries(forRide: rideID)
        } catch {
            throw JournalError.couldNotLoad
        }
    }
}
