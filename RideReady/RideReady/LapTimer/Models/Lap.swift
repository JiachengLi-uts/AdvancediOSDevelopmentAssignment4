//
//  Lap.swift
//

import Foundation


/// **Business rules** (enforced by `RecordTrackDaySessionUseCase` when a session's laps are recorded):
/// A lap's `time` must be a positive duration; a lap that takes zero or negative seconds is not physically possible.
/// `lapNumber` is 1-based and sequential within its session - the first lap of a session is lap 1, not lap 0.
struct Lap: PersistableEntity {
    let id: UUID
    var lapNumber: Int
    var time: TimeInterval
    var notes: String

    init(
        id: UUID = UUID(),
        lapNumber: Int,
        time: TimeInterval,
        notes: String = ""
    ) {
        self.id = id
        self.lapNumber = lapNumber
        self.time = time
        self.notes = notes
    }
}
