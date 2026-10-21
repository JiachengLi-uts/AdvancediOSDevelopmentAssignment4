import Combine
import Foundation
import UIKit

/// New journal entry form: title, description, and an optional photo.
@MainActor
final class JournalEntryViewModel: ObservableObject {
    @Published var title = ""
    @Published var note = ""
    @Published private(set) var photo: Data?
    @Published var riderError: String?

    private let addEntry: AddJournalEntryUseCase

    init(store: RideReadyStoring, journal: RideJournalRepository) {
        addEntry = AddJournalEntryUseCase(store: store, journal: journal)
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func setPhoto(from data: Data) {
        photo = Self.jpegDataForStorage(from: data)
    }

    func removePhoto() {
        photo = nil
    }

    /// Saves the entry. Returns false and sets `riderError` if it couldn't.
    func save() -> Bool {
        do {
            _ = try addEntry.add(title: title, note: note, photo: photo)
            return true
        } catch {
            riderError = error.localizedDescription
            return false
        }
    }

    /// Shrinks the photo so a ride full of photos doesn't fill the iPhone.
    private static func jpegDataForStorage(from data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let maxDimension: CGFloat = 1_600
        let longest = max(image.size.width, image.size.height)
        let scale = longest > maxDimension ? maxDimension / longest : 1
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let scaled = UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return scaled.jpegData(compressionQuality: 0.7) ?? data
    }
}
