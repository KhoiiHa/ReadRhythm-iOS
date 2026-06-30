import Foundation
import SwiftData

#if DEBUG
@MainActor
enum DebugDemoDataSeeder {
    static func seedIfNeeded(in container: ModelContainer) {
        let context = ModelContext(container)
        seedIfNeeded(in: context)
    }

    static func seedIfNeeded(in context: ModelContext) {
        do {
            let existingBooks = try context.fetch(FetchDescriptor<BookEntity>())
            guard existingBooks.isEmpty else {
                DebugLogger.log("[DebugDemoDataSeeder] Skipped: library already contains \(existingBooks.count) books.")
                return
            }

            let books = demoBooks()
            books.forEach(context.insert)
            seedSessions(for: books, in: context)
            seedGoalIfNeeded(in: context)

            try context.save()
            DebugLogger.log("[DebugDemoDataSeeder] Seeded \(books.count) books with demo sessions and a goal.")
        } catch {
            DebugLogger.log("[DebugDemoDataSeeder] Failed: \(error)")
        }
    }

    private static func demoBooks() -> [BookEntity] {
        [
            BookEntity(
                sourceID: "debug-demo-atomic-habits",
                title: "Atomic Habits",
                author: "James Clear",
                thumbnailURL: "https://books.google.com/books/content?id=fFCjDQAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api",
                source: "Demo",
                dateAdded: daysAgo(18),
                subtitle: "An Easy & Proven Way to Build Good Habits & Break Bad Ones",
                publisher: "Avery",
                publishedDate: "2018",
                pageCount: 320,
                language: "en",
                categories: ["Self-Help", "Psychology", "Personal Growth"],
                descriptionText: "Demo-Buch fuer Gewohnheiten, kleine Fortschritte und klare Leseziele.",
                infoLink: URL(string: "https://books.google.com/books?id=fFCjDQAAQBAJ"),
                previewLink: URL(string: "https://books.google.com/books?id=fFCjDQAAQBAJ")
            ),
            BookEntity(
                sourceID: "debug-demo-deep-work",
                title: "Deep Work",
                author: "Cal Newport",
                thumbnailURL: "https://books.google.com/books/content?id=xJY4EAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api",
                source: "Demo",
                dateAdded: daysAgo(12),
                subtitle: "Rules for Focused Success in a Distracted World",
                publisher: "Grand Central Publishing",
                publishedDate: "2016",
                pageCount: 304,
                language: "en",
                categories: ["Productivity", "Focus", "Work"],
                descriptionText: "Demo-Buch fuer Fokus-Sessions, Statistik und Produktivitaetsroutinen.",
                infoLink: URL(string: "https://books.google.com/books?id=xJY4EAAAQBAJ"),
                previewLink: URL(string: "https://books.google.com/books?id=xJY4EAAAQBAJ")
            ),
            BookEntity(
                sourceID: "debug-demo-power-of-now",
                title: "The Power of Now",
                author: "Eckhart Tolle",
                thumbnailURL: "https://books.google.com/books/content?id=sQYqRCIhFAMC&printsec=frontcover&img=1&zoom=1&source=gbs_api",
                source: "Demo",
                dateAdded: daysAgo(7),
                subtitle: "A Guide to Spiritual Enlightenment",
                publisher: "New World Library",
                publishedDate: "1999",
                pageCount: 236,
                language: "en",
                categories: ["Mindfulness", "Spirituality", "Wellness"],
                descriptionText: "Demo-Buch fuer Achtsamkeit, Balance und regelmaessige kurze Sessions.",
                infoLink: URL(string: "https://books.google.com/books?id=sQYqRCIhFAMC"),
                previewLink: URL(string: "https://books.google.com/books?id=sQYqRCIhFAMC")
            )
        ]
    }

    private static func seedSessions(for books: [BookEntity], in context: ModelContext) {
        guard books.count >= 3 else { return }

        let sessions: [(book: BookEntity, daysAgo: Int, minutes: Int, medium: String)] = [
            (books[0], 0, 28, "reading"),
            (books[1], 1, 35, "reading"),
            (books[2], 2, 18, "listening"),
            (books[0], 4, 24, "reading"),
            (books[1], 7, 42, "reading"),
            (books[2], 12, 30, "listening")
        ]

        for item in sessions {
            context.insert(
                ReadingSessionEntity(
                    id: sessionID(book: item.book.sourceID, daysAgo: item.daysAgo, medium: item.medium),
                    date: daysAgo(item.daysAgo),
                    minutes: item.minutes,
                    book: item.book,
                    medium: item.medium
                )
            )
        }
    }

    private static func seedGoalIfNeeded(in context: ModelContext) {
        let activeGoals = (try? context.fetch(ReadingGoalEntity.activeGoalFetchDescriptor)) ?? []
        guard activeGoals.isEmpty else { return }

        context.insert(
            ReadingGoalEntity(
                id: UUID(uuidString: "11111111-1111-4111-8111-111111111111")!,
                createdAt: daysAgo(14),
                period: .monthly,
                targetMinutes: 600,
                targetBooks: nil,
                isActive: true
            )
        )
    }

    private static func daysAgo(_ value: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let base = calendar.date(byAdding: .day, value: -value, to: today) ?? today
        return calendar.date(byAdding: .hour, value: 20, to: base) ?? base
    }

    private static func sessionID(book sourceID: String, daysAgo: Int, medium: String) -> UUID {
        let key = "\(sourceID)-\(daysAgo)-\(medium)"
        var hash = UInt64(14_695_981_039_346_656_037)
        for byte in key.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }

        let suffix = String(format: "%012llx", hash & 0x0000_FFFF_FFFF_FFFF)
        return UUID(uuidString: "22222222-2222-4222-8222-\(suffix)")!
    }
}
#endif
