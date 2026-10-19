//
//  Session.swift
//

import Foundation

enum WeatherCondition: String, Codable, CaseIterable, Identifiable, Hashable {
    case dry = "Dry"
    case damp = "Damp"
    case wet = "Wet"
    case mixed = "Mixed"

    var id: String { rawValue }
}

/// **Business rules** (enforced by `RecordTrackDaySessionUseCase` when a session is recorded):
/// The referenced vehicle and track must already be registered in RaceLog - a session can't be logged against equipment the app doesn't know about yet.
/// The session `date` cannot be in the future, because a session represents an outing that has already taken place.
/// At least one lap must be recorded — a session with no lap times carries no performance data and isn't worth logging.

struct Session: PersistableEntity {
    let id: UUID
    var date: Date
    var vehicleID: UUID
    var trackID: UUID
    var weather: WeatherCondition
    var trackCondition: String
    var setupNotes: String
    var laps: [Lap]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        vehicleID: UUID,
        trackID: UUID,
        weather: WeatherCondition = .dry,
        trackCondition: String = "",
        setupNotes: String = "",
        laps: [Lap] = []
    ) {
        self.id = id
        self.date = date
        self.vehicleID = vehicleID
        self.trackID = trackID
        self.weather = weather
        self.trackCondition = trackCondition
        self.setupNotes = setupNotes
        self.laps = laps
    }
}

extension Session: LapStatisticsProviding {}

extension Session: TrackDayEventRecord {
    var eventDate: Date { date }

    func eventSummary(vehicleName: String, trackName: String) -> String {
        let lapDescription: String
        if let fastest = fastestLap {
            let lapWord = lapCount == 1 ? "lap" : "laps"
            lapDescription = "\(lapCount) \(lapWord), best \(fastest.time.formattedTime)"
        } else {
            lapDescription = "no laps recorded"
        }
        return "\(trackName) — \(vehicleName) — \(lapDescription)"
    }
}
