import Foundation

/// Leichtgewichtiges Modell für Remote-Buchdetails (Google Books).
/// Enthält nur lesbare Felder – kein Persistenz-State.
struct DiscoverBookDetail: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let authors: [String]
    let publisher: String?
    let publishedDate: String?
    let pageCount: Int?
    let categories: [String]
    let description: String?
    let thumbnailURL: URL?
    let previewLink: URL?

    init(id: String,
         title: String,
         subtitle: String?,
         authors: [String],
         publisher: String?,
         publishedDate: String?,
         pageCount: Int?,
         categories: [String],
         description: String?,
         thumbnailURL: URL?,
         previewLink: URL?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.authors = authors
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.pageCount = pageCount
        self.categories = categories
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.previewLink = previewLink
    }

    init(from remote: RemoteBook) {
        self.init(
            id: remote.id,
            title: remote.title,
            subtitle: remote.subtitle,
            authors: remote.authors,
            publisher: remote.publisher,
            publishedDate: remote.publishedDate,
            pageCount: remote.pageCount,
            categories: remote.categories,
            description: remote.description,
            thumbnailURL: remote.thumbnailURL,
            previewLink: remote.previewLink
        )
    }

    var authorsDisplay: String {
        let trimmed = authors
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return trimmed.isEmpty ? "—" : trimmed.joined(separator: ", ")
    }
}
