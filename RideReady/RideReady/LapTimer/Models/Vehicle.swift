//
//  Vehicle.swift
//

import Foundation

enum VehicleType: String, Codable, CaseIterable, Identifiable, Hashable {
    case car = "Car"
    case motorcycle = "Motorcycle"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .car: return "car.fill"
        case .motorcycle: return "bicycle"
        }
    }
}


/// **Business rules** (enforced by `RegisterVehicleUseCase` at the point a vehicle is added — a `Vehicle` value itself is just data):
/// A vehicle must have a non-blank name, because the name is how the racer picks it out when starting a new session and when reviewing session history.
/// No two vehicles may share the same name (case-insensitive), so that session history is never ambiguous about which vehicle a lap time belongs to.
/// If a model year is supplied, it must fall within a plausible range (1900 through next year), since this is a real-world manufacturing year, not an arbitrary number.

struct Vehicle: PersistableEntity {
    let id: UUID
    var name: String
    var type: VehicleType
    var make: String
    var model: String
    var year: Int?
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        type: VehicleType,
        make: String = "",
        model: String = "",
        year: Int? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.make = make
        self.model = model
        self.year = year
        self.notes = notes
    }

    var makeAndModel: String {
        [make, model].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
