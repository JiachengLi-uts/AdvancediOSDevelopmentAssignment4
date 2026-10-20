//
//  SessionRow.swift
//


import SwiftUI

struct SessionRow: View {
    @EnvironmentObject var dataStore: DataStore
    let session: Session

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(trackName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(vehicleName)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let fastest = session.fastestLap {
                    Text(fastest.time.formattedTime)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.accentColor)
                } else {
                    Text("No laps")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                }
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(14)
        .cardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(session.eventSummary(vehicleName: vehicleName, trackName: trackName))
    }

    private var trackName: String {
        dataStore.track(for: session.trackID)?.name ?? "Unknown Track"
    }

    private var vehicleName: String {
        dataStore.vehicle(for: session.vehicleID)?.name ?? "Unknown Vehicle"
    }
}
