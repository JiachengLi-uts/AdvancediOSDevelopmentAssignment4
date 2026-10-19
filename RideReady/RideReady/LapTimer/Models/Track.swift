//
//  Track.swift
//

import Foundation

/// **Business rules** (enforced by `RegisterTrackUseCase` when a track is added):
/// A track must have a non-blank name, since the name is how the racer selects it when logging a session and browsing history.
/// No two tracks may share the same name (case-insensitive), so that "personal best at this track" is always unambiguous.
/// If a track length is supplied, it must be a positive distance - a circuit cannot have zero or negative length.
struct Track: PersistableEntity {
    let id: UUID
    var name: String
    var location: String
    var lengthMeters: Double?
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        location: String = "",
        lengthMeters: Double? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.lengthMeters = lengthMeters
        self.notes = notes
    }

    var formattedLength: String? {
        guard let lengthMeters else { return nil }
        if lengthMeters >= 1000 {
            return String(format: "%.2f km", lengthMeters / 1000)
        }
        return String(format: "%.0f m", lengthMeters)
    }
}
