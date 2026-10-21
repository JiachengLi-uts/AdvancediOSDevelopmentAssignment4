import Foundation
@testable import RideReady

extension RideReadyStoring {
    /// Logs a finished walk-around of the Yamaha MT-07, as the Bike tab would.
    func logPreRideCheck(_ readiness: RideReadiness, at date: Date) {
        let motorcycle = Motorcycle.yamahaMT07()
        let result: InspectionResult = readiness == .readyToRide ? .ok : .needsAttention
        save(PreRideInspection(
            id: UUID(),
            motorcycle: motorcycle,
            startedAt: date,
            findings: motorcycle.requiredInspectionItems().map { InspectionFinding(item: $0, result: result) },
            completedAt: date,
            readiness: readiness
        ))
    }
}
