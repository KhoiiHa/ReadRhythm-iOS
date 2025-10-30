//
//  ReadingProgressRepository.swift
//  ReadRhythm
//
//  Simple persistence for the reader's current page per book.
//

import Foundation

final class ReadingProgressRepository {
    static let shared = ReadingProgressRepository()

    private let defaults: UserDefaults
    private let keyPrefix = "reader.progress."

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func storedPage(for bookID: String) -> Int? {
        let key = key(for: bookID)
        guard defaults.object(forKey: key) != nil else { return nil }
        return defaults.integer(forKey: key)
    }

    func currentPage(for bookID: String, totalPages: Int) -> Int {
        guard let stored = storedPage(for: bookID) else { return 0 }
        return clamp(stored, totalPages: totalPages)
    }

    func update(page: Int, for bookID: String, totalPages: Int) {
        let clamped = clamp(page, totalPages: totalPages)
        defaults.set(clamped, forKey: key(for: bookID))
    }

    func resetProgress(for bookID: String) {
        defaults.removeObject(forKey: key(for: bookID))
    }

    private func key(for bookID: String) -> String {
        keyPrefix + bookID
    }

    private func clamp(_ page: Int, totalPages: Int) -> Int {
        guard totalPages > 0 else { return 0 }
        return min(max(page, 0), totalPages - 1)
    }
}
