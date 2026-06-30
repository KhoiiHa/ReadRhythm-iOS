import Foundation

#if DEBUG
enum DiscoverSampleBooks {
    static func results(for query: String, category: DiscoverCategory?, limit: Int) -> [RemoteBook] {
        let normalizedQuery = query
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let base: [SampleBook]
        if let category {
            base = samples.filter { $0.sampleCategories.contains(category) }
        } else {
            base = samples
        }

        let filtered = normalizedQuery.isEmpty ? base : base.filter { item in
            item.searchText.contains(normalizedQuery)
        }

        let source = filtered.isEmpty ? base : filtered
        return Array(source.prefix(max(1, limit))).map(\.book)
    }

    private static let samples: [SampleBook] = [
        SampleBook(
            book: RemoteBook(
                id: "debug-sample-atomic-habits",
                title: "Atomic Habits",
                subtitle: "An Easy & Proven Way to Build Good Habits & Break Bad Ones",
                authors: ["James Clear"],
                publisher: "Avery",
                publishedDate: "2018",
                pageCount: 320,
                language: "en",
                infoLink: URL(string: "https://books.google.com/books?id=fFCjDQAAQBAJ"),
                categories: ["Self-Help", "Psychology", "Personal Growth"],
                description: "Ein praxisnahes Beispielbuch fuer Habit-Tracking, Ziele und kleine Fortschritte. Gut geeignet, um Discover, Detailansicht und Session-Flow zu pruefen.",
                thumbnailURL: URL(string: "https://books.google.com/books/content?id=fFCjDQAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api"),
                previewLink: URL(string: "https://books.google.com/books?id=fFCjDQAAQBAJ")
            ),
            sampleCategories: [.selfHelp, .psychology]
        ),
        SampleBook(
            book: RemoteBook(
                id: "debug-sample-deep-work",
                title: "Deep Work",
                subtitle: "Rules for Focused Success in a Distracted World",
                authors: ["Cal Newport"],
                publisher: "Grand Central Publishing",
                publishedDate: "2016",
                pageCount: 304,
                language: "en",
                infoLink: URL(string: "https://books.google.com/books?id=xJY4EAAAQBAJ"),
                categories: ["Productivity", "Focus", "Work"],
                description: "Ein starkes Demo-Buch fuer Fokus-Sessions, Statistik und Fortschritt. Es macht sichtbar, wie ReadRhythm Lesezeit in Aktivitaet uebersetzt.",
                thumbnailURL: URL(string: "https://books.google.com/books/content?id=xJY4EAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api"),
                previewLink: URL(string: "https://books.google.com/books?id=xJY4EAAAQBAJ")
            ),
            sampleCategories: [.selfHelp, .creativity]
        ),
        SampleBook(
            book: RemoteBook(
                id: "debug-sample-power-of-now",
                title: "The Power of Now",
                subtitle: "A Guide to Spiritual Enlightenment",
                authors: ["Eckhart Tolle"],
                publisher: "New World Library",
                publishedDate: "1999",
                pageCount: 236,
                language: "en",
                infoLink: URL(string: "https://books.google.com/books?id=sQYqRCIhFAMC"),
                categories: ["Mindfulness", "Spirituality", "Wellness"],
                description: "Beispieldaten fuer Achtsamkeit und Balance. Das Buch eignet sich, um Kategorie-Chips, Detail-Metadaten und Bibliotheksimport zu testen.",
                thumbnailURL: URL(string: "https://books.google.com/books/content?id=sQYqRCIhFAMC&printsec=frontcover&img=1&zoom=1&source=gbs_api"),
                previewLink: URL(string: "https://books.google.com/books?id=sQYqRCIhFAMC")
            ),
            sampleCategories: [.mindfulness, .wellness, .philosophy]
        ),
        SampleBook(
            book: RemoteBook(
                id: "debug-sample-mans-search",
                title: "Man's Search for Meaning",
                subtitle: nil,
                authors: ["Viktor E. Frankl"],
                publisher: "Beacon Press",
                publishedDate: "2006",
                pageCount: 184,
                language: "en",
                infoLink: URL(string: "https://books.google.com/books?id=F-Q_xGjWBi8C"),
                categories: ["Philosophy", "Psychology", "Memoir"],
                description: "Ein kompaktes Beispiel fuer sinnorientiertes Lesen. Hilft beim Testen von langen Beschreibungen, Kategorien und Profil-/History-Flows.",
                thumbnailURL: URL(string: "https://books.google.com/books/content?id=F-Q_xGjWBi8C&printsec=frontcover&img=1&zoom=1&source=gbs_api"),
                previewLink: URL(string: "https://books.google.com/books?id=F-Q_xGjWBi8C")
            ),
            sampleCategories: [.philosophy, .psychology]
        ),
        SampleBook(
            book: RemoteBook(
                id: "debug-sample-big-magic",
                title: "Big Magic",
                subtitle: "Creative Living Beyond Fear",
                authors: ["Elizabeth Gilbert"],
                publisher: "Riverhead Books",
                publishedDate: "2015",
                pageCount: 288,
                language: "en",
                infoLink: URL(string: "https://books.google.com/books?id=An1rCgAAQBAJ"),
                categories: ["Creativity", "Writing", "Inspiration"],
                description: "Ein visuelles und inhaltliches Beispiel fuer den Kreativitaetsbereich. Nuetzlich, um Carousel, Grid und Detaildarstellung zu pruefen.",
                thumbnailURL: URL(string: "https://books.google.com/books/content?id=An1rCgAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api"),
                previewLink: URL(string: "https://books.google.com/books?id=An1rCgAAQBAJ")
            ),
            sampleCategories: [.creativity, .selfHelp]
        ),
        SampleBook(
            book: RemoteBook(
                id: "debug-sample-normal-people",
                title: "Normal People",
                subtitle: nil,
                authors: ["Sally Rooney"],
                publisher: "Faber & Faber",
                publishedDate: "2018",
                pageCount: 273,
                language: "en",
                infoLink: URL(string: "https://books.google.com/books?id=POJQDwAAQBAJ"),
                categories: ["Fiction", "Romance", "Literary Fiction"],
                description: "Ein Fiction-Beispiel fuer Kategorien ausserhalb von Self-Improvement. Damit laesst sich pruefen, ob ReadRhythm auch Romane sauber behandelt.",
                thumbnailURL: URL(string: "https://books.google.com/books/content?id=POJQDwAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api"),
                previewLink: URL(string: "https://books.google.com/books?id=POJQDwAAQBAJ")
            ),
            sampleCategories: [.fictionRomance]
        )
    ]
}

private struct SampleBook {
    let book: RemoteBook
    let sampleCategories: [DiscoverCategory]

    var searchText: String {
        ([book.title, book.subtitle, book.publisher, book.description] + book.authors + book.categories)
            .compactMap { $0 }
            .joined(separator: " ")
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
#endif
