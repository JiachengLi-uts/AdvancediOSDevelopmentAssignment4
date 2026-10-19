//
//  RegisterTrackUseCase.swift
//

import Foundation

struct RegisterTrackUseCase<TrackStore: PersistenceStore> where TrackStore.Entity == Track {
    let trackStore: TrackStore

    init(trackStore: TrackStore) {
        self.trackStore = trackStore
    }

    /// Registers a new track, validating it against RaceLog's registration rules first.
    /// Throws: `TrackRegistrationError` if the name is missing, already taken or the supplied length isn't a positive distance.
    @discardableResult
    func execute(
        name: String,
        location: String,
        lengthMeters: Double?,
        notes: String
    ) throws -> Track {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw TrackRegistrationError.missingName
        }

        let existingTracks = trackStore.loadAll()
        if let duplicate = existingTracks.first(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) {
            throw TrackRegistrationError.duplicateName(existingTrackName: duplicate.name)
        }

        if let lengthMeters, lengthMeters <= 0 {
            throw TrackRegistrationError.invalidLength(lengthMeters: lengthMeters)
        }

        let track = Track(name: trimmedName, location: location, lengthMeters: lengthMeters, notes: notes)
        trackStore.save(existingTracks + [track])
        return track
    }
}

enum TrackRegistrationError: LocalizedError, Equatable {
    /// Who hits this: a racer left the name field empty and tried to save.
    /// Recovery: type a name before saving.
    case missingName

    /// Who hits this: a racer tried to register a track whose name matches one already in their list.
    /// Recovery: use the existing entry, or pick a different name.
    case duplicateName(existingTrackName: String)

    /// Who hits this: a racer entered a track length that's zero or negative.
    /// Recovery: correct the length, or leave it blank if unknown.
    case invalidLength(lengthMeters: Double)

    var errorDescription: String? {
        switch self {
        case .missingName:
            return "Give this track a name so you can select it when logging a session."
        case .duplicateName(let existingTrackName):
            return "You already have a track named \"\(existingTrackName)\". Use its existing entry, or choose a different name."
        case .invalidLength(let lengthMeters):
            let formattedLength = String(format: "%.0f", lengthMeters)
            return "Track length must be a positive distance — \(formattedLength) m isn't valid. Leave it blank if you don't know the length."
        }
    }
}
