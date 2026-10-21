import PhotosUI
import SwiftUI
import UIKit

/// Logs a moment during a ride: a title, a description, and a photo.
struct JournalEntryView: View {
    @StateObject private var viewModel: JournalEntryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pickerItem: PhotosPickerItem?
    @State private var showingError = false
    let onSave: () -> Void

    init(viewModel: @autoclosure @escaping () -> JournalEntryViewModel, onSave: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("e.g. Lookout over the bay", text: $viewModel.title)
                }
                Section("Description") {
                    TextField("What's worth remembering here?", text: $viewModel.note, axis: .vertical)
                        .lineLimit(3...8)
                }
                Section("Photo") {
                    if let photo = viewModel.photo, let image = UIImage(data: photo) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .accessibilityLabel("Photo for this entry")
                        Button("Remove photo", role: .destructive) {
                            viewModel.removePhoto()
                            pickerItem = nil
                        }
                    }
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Choose from library", systemImage: "photo.on.rectangle")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New journal entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save() {
                            onSave()
                            dismiss()
                        } else {
                            showingError = true
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .onChange(of: pickerItem) { _, item in
                Task {
                    guard let item,
                          let data = try? await item.loadTransferable(type: Data.self) else {
                        return
                    }
                    viewModel.setPhoto(from: data)
                }
            }
            .alert("Couldn't save this entry", isPresented: $showingError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(viewModel.riderError ?? "")
            })
        }
    }
}

/// One journal entry: photo thumbnail, title, time, and description.
struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let photo = entry.photo, let image = UIImage(data: photo) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.subheadline.weight(.semibold))
                Text(DayTimeText.time(entry.loggedAt))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.footnote)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

/// Where a recent ride leads: the journal entries logged during it.
struct RideJournalRoute: Hashable {
    let rideID: UUID
    let title: String
}

struct RideJournalView: View {
    let title: String
    let entries: [JournalEntry]

    var body: some View {
        List {
            if entries.isEmpty {
                Text("No journal entries on this ride.")
                    .foregroundStyle(.secondary)
            }
            ForEach(entries) { entry in
                JournalEntryRow(entry: entry)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
