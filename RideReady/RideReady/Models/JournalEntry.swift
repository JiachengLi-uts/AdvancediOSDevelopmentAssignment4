import Foundation

/// Something the rider logged during a ride: a view, a café, a pothole to
/// avoid next time.
///
/// Business Rule: a title is required; the note and photo are optional.
struct JournalEntry: Identifiable, Equatable {
    static let titleLimit = 60
    static let noteLimit = 1_000

    let id: UUID
    let rideID: UUID
    let title: String
    let note: String
    let loggedAt: Date
    let photo: Data?
}
