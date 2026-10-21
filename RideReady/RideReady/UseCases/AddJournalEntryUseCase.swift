import Foundation

/// Logs a moment during the ride in progress.
///
/// Business Rules:
/// - Entries can only be added while a ride is in progress, riding or on a break.
/// - The title is required, trimmed, and at most 60 characters; the note is
///   at most 1,000 characters.
struct AddJournalEntryUseCase {
    let store: RideReadyStoring
    let journal: RideJournalRepository
    let now: () -> Date

    init(store: RideReadyStoring, journal: RideJournalRepository, now: @escaping () -> Date = Date.init) {
        self.store = store
        self.journal = journal
        self.now = now
    }

    func add(title: String, note: String, photo: Data?) throws -> JournalEntry {
        guard let ride = store.activeRide() else {
            throw JournalError.noRideInProgress
        }
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw JournalError.titleMissing
        }
        guard title.count <= JournalEntry.titleLimit, note.count <= JournalEntry.noteLimit else {
            throw JournalError.tooLong
        }

        let entry = JournalEntry(id: UUID(), rideID: ride.id, title: title, note: note, loggedAt: now(), photo: photo)
        do {
            try journal.save(entry)
        } catch {
            throw JournalError.couldNotSave
        }
        return entry
    }
}

/// Failures when Alex logs or opens a ride journal.
enum JournalError: LocalizedError, Equatable {
    case noRideInProgress
    case titleMissing
    case tooLong
    case couldNotSave
    case couldNotLoad

    var errorDescription: String? {
        switch self {
        case .noRideInProgress:
            return "You can only add to the journal during a ride. Start a ride first."
        case .titleMissing:
            return "Give this entry a title so you can find it later."
        case .tooLong:
            return "Keep the title to \(JournalEntry.titleLimit) characters and the description to \(JournalEntry.noteLimit)."
        case .couldNotSave:
            return "Your journal entry couldn't be saved. Check your iPhone has free storage and try again."
        case .couldNotLoad:
            return "This ride's journal couldn't be opened. Try again."
        }
    }
}
