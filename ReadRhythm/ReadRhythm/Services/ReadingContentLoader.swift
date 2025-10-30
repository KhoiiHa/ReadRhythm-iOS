//
//  ReadingContentLoader.swift
//  ReadRhythm
//
//  Loads demo reading content from bundled plain text assets.
//

import Foundation

final class ReadingContentLoader {
    static let shared = ReadingContentLoader()

    private struct Resource {
        let name: String
        let fileExtension: String
        let subdirectory: String?
        let title: String?
    }

    private let bundle: Bundle
    private let separator = "\n---\n"

    private let resourceMap: [String: Resource] = [
        "demo-atomic-habits": Resource(name: "demo-atomic-habits", fileExtension: "txt", subdirectory: "Reader", title: "Atomic Habits"),
        "demo-deep-work": Resource(name: "demo-deep-work", fileExtension: "txt", subdirectory: "Reader", title: "Deep Work")
    ]

    private init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func content(forBookID bookID: String) -> ReadingContent? {
        guard let resource = resourceMap[bookID] else { return nil }
        return loadContent(resource: resource, bookID: bookID)
    }

    private func loadContent(resource: Resource, bookID: String) -> ReadingContent? {
        guard let url = bundle.url(
            forResource: resource.name,
            withExtension: resource.fileExtension,
            subdirectory: resource.subdirectory
        ) else {
            #if DEBUG
            DebugLogger.log("⚠️ Reader asset missing for \(bookID)")
            #endif
            return nil
        }

        guard let rawText = try? String(contentsOf: url, encoding: .utf8) else {
            #if DEBUG
            DebugLogger.log("⚠️ Unable to decode reader asset for \(bookID)")
            #endif
            return nil
        }

        let pages = rawText
            .components(separatedBy: separator)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        guard pages.isEmpty == false else { return nil }

        return ReadingContent(
            id: resource.name,
            bookID: bookID,
            title: resource.title,
            pages: pages
        )
    }
}
