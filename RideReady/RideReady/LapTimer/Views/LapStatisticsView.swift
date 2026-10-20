//
//  LapStatisticsView.swift
//

import SwiftUI
import Charts

struct LapStatisticsView: View {
    @EnvironmentObject var dataStore: DataStore
    let session: Session

    private var vehicle: Vehicle? {
        dataStore.vehicle(for: session.vehicleID)
    }

    private var track: Track? {
        dataStore.track(for: session.trackID)
    }

    private var previousBest: Lap? {
        dataStore.sessions
            .filter {
                $0.trackID == session.trackID
                    && $0.vehicleID == session.vehicleID
                    && $0.id != session.id
                    && $0.date < session.date
            }
            .compactMap { $0.fastestLap }
            .min { $0.time < $1.time }
    }

    private var sortedLaps: [Lap] {
        session.laps.sorted { $0.lapNumber < $1.lapNumber }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                if let fastest = session.fastestLap {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Fastest Lap")
                        let components = fastest.time.lapTimeComponents
                        HStack(spacing: 10) {
                            StatBoxView(value: "\(components.minutes)", caption: "Min", accent: .accentColor)
                            StatBoxView(value: String(format: "%02d", components.seconds), caption: "Sec", accent: .accentColor)
                            StatBoxView(value: String(format: "%03d", components.milliseconds), caption: "Ms", accent: .accentColor)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "Statistics")
                    VStack(spacing: 0) {
                        if let average = session.averageLapTime {
                            StatRow(label: "Average Lap", value: average.formattedTime)
                            CardDivider()
                        }
                        StatRow(label: "Number of Laps", value: "\(session.lapCount)")
                        if let consistency = session.consistency {
                            CardDivider()
                            StatRow(label: "Consistency (\u{03C3})", value: consistency.formattedTime)
                        }
                        if let previousBest {
                            CardDivider()
                            StatRow(label: "Previous Best", value: previousBest.time.formattedTime)
                            if let fastest = session.fastestLap {
                                let delta = fastest.time - previousBest.time
                                CardDivider()
                                StatRow(
                                    label: "Change",
                                    value: deltaDescription(delta),
                                    valueColor: delta <= 0 ? .green : .red
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .cardStyle()
                }

                if sortedLaps.count > 1 {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Performance History")
                        Chart(sortedLaps) { lap in
                            LineMark(
                                x: .value("Lap", lap.lapNumber),
                                y: .value("Time", lap.time)
                            )
                            .foregroundStyle(Color.accentColor)
                            PointMark(
                                x: .value("Lap", lap.lapNumber),
                                y: .value("Time", lap.time)
                            )
                            .foregroundStyle(Color.accentColor)
                        }
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisGridLine().foregroundStyle(Color.cardDivider)
                                AxisValueLabel().foregroundStyle(Color.secondary)
                            }
                        }
                        .chartYAxis {
                            AxisMarks { _ in
                                AxisGridLine().foregroundStyle(Color.cardDivider)
                                AxisValueLabel().foregroundStyle(Color.secondary)
                            }
                        }
                        .frame(height: 200)
                        .padding(14)
                        .cardStyle()
                    }
                }

                if !sortedLaps.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        SectionHeader(title: "Laps")
                        VStack(spacing: 0) {
                            ForEach(Array(sortedLaps.enumerated()), id: \.element.id) { index, lap in
                                if index > 0 { CardDivider() }
                                StatRow(
                                    label: "Lap \(lap.lapNumber)",
                                    value: lap.time.formattedTime,
                                    valueColor: lap.id == session.fastestLap?.id ? .accentColor : .primary
                                )
                            }
                        }
                        .padding(.horizontal, 14)
                        .cardStyle()
                    }
                }

                if !session.setupNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Setup Notes")
                        Text(session.setupNotes)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.primary)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardStyle()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color.screenBackground.ignoresSafeArea())
        .navigationTitle("Session Statistics")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(track?.name ?? "Unknown Track")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)
            Text(vehicle?.name ?? "Unknown Vehicle")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
            Text(session.date.formatted(date: .long, time: .omitted))
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func deltaDescription(_ delta: TimeInterval) -> String {
        let magnitude = abs(delta).formattedTime
        return delta <= 0 ? "-\(magnitude)" : "+\(magnitude)"
    }
}
