//
//  NewSessionView.swift
//

import SwiftUI

struct NewSessionView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVehicleID: UUID?
    @State private var selectedTrackID: UUID?
    @State private var date = Date()
    @State private var weather: WeatherCondition = .dry
    @State private var trackCondition = ""
    @State private var setupNotes = ""
    @State private var laps: [Lap] = []
    @State private var newLapTimeText = ""
    @State private var showingInvalidLapAlert = false
    @State private var errorMessage: String?

    private var canSave: Bool {
        selectedVehicleID != nil && selectedTrackID != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Session") {
                    if dataStore.vehicles.isEmpty || dataStore.tracks.isEmpty {
                        Text("Set up your bike in the Bike tab and register at least one track before recording a session.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Vehicle", selection: $selectedVehicleID) {
                            Text("Select a vehicle").tag(nil as UUID?)
                            ForEach(dataStore.vehicles) { vehicle in
                                Text(vehicle.name).tag(vehicle.id as UUID?)
                            }
                        }

                        Picker("Track", selection: $selectedTrackID) {
                            Text("Select a track").tag(nil as UUID?)
                            ForEach(dataStore.tracks) { track in
                                Text(track.name).tag(track.id as UUID?)
                            }
                        }
                    }

                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)

                    Picker("Weather", selection: $weather) {
                        ForEach(WeatherCondition.allCases) { condition in
                            Text(condition.rawValue).tag(condition)
                        }
                    }

                    TextField("Track Condition (optional)", text: $trackCondition)
                }

                Section("Setup Notes") {
                    TextEditor(text: $setupNotes)
                        .frame(minHeight: 60)
                }

                Section("Lap Times") {
                    if laps.isEmpty {
                        Text("No laps added yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(laps) { lap in
                            HStack {
                                Text("Lap \(lap.lapNumber)")
                                Spacer()
                                Text(lap.time.formattedTime)
                                    .fontWeight(isFastest(lap) ? .bold : .regular)
                            }
                        }
                        .onDelete(perform: deleteLap)
                    }

                    HStack {
                        TextField("e.g. 1:23.456", text: $newLapTimeText)
                            .onSubmit(addLap)
                            #if os(iOS)
                            .keyboardType(.numbersAndPunctuation)
                            #endif
                        Button(action: addLap) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(TimeInterval(fromLapString: newLapTimeText) == nil)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.screenBackground.ignoresSafeArea())
            .navigationTitle("Record Session")
            .onAppear {
                if selectedVehicleID == nil {
                    selectedVehicleID = dataStore.vehicles.first?.id
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Record Session") { save() }
                        .disabled(!canSave)
                }
            }
            .alert("Invalid Lap Time", isPresented: $showingInvalidLapAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Enter a lap time as minutes:seconds.milliseconds (e.g. 1:23.456) or as plain seconds (e.g. 83.456).")
            }
            .alert(
                "Can't Record Session",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { isPresented in if !isPresented { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func isFastest(_ lap: Lap) -> Bool {
        laps.min(by: { $0.time < $1.time })?.id == lap.id
    }

    private func addLap() {
        guard let time = TimeInterval(fromLapString: newLapTimeText) else {
            if !newLapTimeText.trimmingCharacters(in: .whitespaces).isEmpty {
                showingInvalidLapAlert = true
            }
            return
        }
        let lap = Lap(lapNumber: laps.count + 1, time: time)
        laps.append(lap)
        newLapTimeText = ""
    }

    private func deleteLap(at offsets: IndexSet) {
        laps.remove(atOffsets: offsets)
        for index in laps.indices {
            laps[index].lapNumber = index + 1
        }
    }

    private func save() {
        guard let vehicleID = selectedVehicleID, let trackID = selectedTrackID else { return }
        do {
            try dataStore.recordSession(
                vehicleID: vehicleID,
                trackID: trackID,
                date: date,
                weather: weather,
                trackCondition: trackCondition,
                setupNotes: setupNotes,
                laps: laps
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NewSessionView()
        .environmentObject(DataStore(rideReadyStore: UserDefaultsRideReadyStore()))
}
