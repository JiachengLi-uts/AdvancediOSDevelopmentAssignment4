//
//  InMemoryStore.swift
//


import Foundation
@testable import RideReady

final class InMemoryStore<Entity: PersistableEntity>: PersistenceStore {
    private var items: [Entity]

    init(items: [Entity] = []) {
        self.items = items
    }

    func loadAll() -> [Entity] {
        items
    }

    func save(_ items: [Entity]) {
        self.items = items
    }
}
