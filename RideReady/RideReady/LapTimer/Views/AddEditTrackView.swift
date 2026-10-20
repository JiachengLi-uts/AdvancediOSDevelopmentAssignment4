//
//  AddEditTrackView.swift
//


import SwiftUI

struct AddEditTrackView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    var trackToEdit: Track?

    @State private var name: String
    @State private var location: String
    @State private var lengthText: String
    @State private var notes: String
    @State private var errorMessage: String?

    init(trackToEdit: Track? = nil) {
        self.trackToEdit = trackToEdit
        _name = State(initialValue: trackToEdit?.name ?? "")
        _location = State(initialValue: trackToEdit?.location ?? "")
        _lengthText = State(initialValue: trackToEdit?.lengthMeters.map { String(format: "%.0f", $0) } ?? "")
        _notes = State(initialValue: trackToEdit?.notes ?? "")
    }

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isEditing: Bool {
        trackToEdit != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Track") {
                    TextField("Name", text: $name)
                    TextField("Location", text: $location)
                    TextField("Length (metres)", text: $lengthText)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.screenBackground.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Track" : "Register Track")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Register") { save() }
                        .disabled(!isNameValid)
                }
            }
            .alert(
                "Can't Register Track",
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

    private func save() {
        let length = Double(lengthText)

        if let existing = trackToEdit {
            var updated = existing
            updated.name = name
            updated.location = location
            updated.lengthMeters = length
            updated.notes = notes
            dataStore.updateTrack(updated)
            dismiss()
        } else {
            do {
                try dataStore.registerTrack(name: name, location: location, lengthMeters: length, notes: notes)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    AddEditTrackView()
        .environmentObject(DataStore(rideReadyStore: UserDefaultsRideReadyStore()))
}
