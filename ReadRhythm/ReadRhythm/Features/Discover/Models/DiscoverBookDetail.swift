import Foundation

/// Präsentationsmodell für Remote-Buchdetails aus Google Books.
/// Kapselt die rohen DTO-Daten und liefert formatierte Strings für das UI.
struct DiscoverBookDetail: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let authors: [String]
    let publisher: String?
    let publishedYear: String?
    let pageCount: Int?
    let categories: [String]
    let description: String?
    let thumbnailURL: URL?
    let previewLink: URL?
    let infoLink: URL?
    let languageCode: String?
    let averageRating: Double?
    let ratingsCount: Int?

    /// Originales RemoteBook – wird benötigt, wenn das Buch in die Bibliothek übernommen wird.
    private let backingRemote: RemoteBook

    init(
        id: String,
        title: String,
        subtitle: String?,
        authors: [String],
        publisher: String?,
        publishedYear: String?,
        pageCount: Int?,
        categories: [String],
        description: String?,
        thumbnailURL: URL?,
        previewLink: URL?,
        infoLink: URL?,
        languageCode: String?,
        averageRating: Double?,
        ratingsCount: Int?,
        remote: RemoteBook
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.authors = authors
        self.publisher = publisher
        self.publishedYear = publishedYear
        self.pageCount = pageCount
        self.categories = categories
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.previewLink = previewLink
        self.infoLink = infoLink
        self.languageCode = languageCode
        self.averageRating = averageRating
        self.ratingsCount = ratingsCount
        self.backingRemote = remote
    }

    init(from remote: RemoteBook) {
        self.init(
            id: remote.id,
            title: remote.title,
            subtitle: remote.subtitle,
            authors: remote.authors,
            publisher: remote.publisher,
            publishedYear: remote.publishedYear,
            pageCount: remote.pageCount,
            categories: remote.categories,
            description: remote.description,
            thumbnailURL: remote.thumbnailURL,
            previewLink: remote.previewLink,
            infoLink: remote.infoLink,
            languageCode: remote.languageCode,
            averageRating: remote.averageRating,
            ratingsCount: remote.ratingsCount,
            remote: remote
        )
    }

    var remote: RemoteBook { backingRemote }

    var authorsDisplay: String {
        let trimmed = authors
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return trimmed.isEmpty ? "—" : trimmed.joined(separator: ", ")
    }

    var languageBadge: String? {
        guard let code = languageCode?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty else {
            return nil
        }
        let baseCode = code.split(separator: "-").first.map(String.init) ?? code
        let scalar = baseCode.prefix(2)
        return scalar.uppercased()
    }

    var languageDisplay: String? {
        guard let code = languageCode?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty else {
            return nil
        }

        let normalized = code.lowercased()
        if let localized = Locale.current.localizedString(forIdentifier: normalized)
            ?? Locale.current.localizedString(forLanguageCode: normalized) {
            return localized.capitalized(with: Locale.current)
        }

        return code.uppercased()
    }

    var hasMetaData: Bool {
        publisher != nil || publishedYear != nil || pageCount != nil
    }

    func pagesDisplay(unitKey: String) -> String? {
        guard let pageCount else { return nil }
        let unit = String(localized: String.LocalizationValue(unitKey))
        return "\(pageCount) \(unit)"
    }

    var externalURL: URL? {
        previewLink ?? infoLink
    }

    var averageRatingDisplay: String? {
        guard let averageRating else { return nil }
        return DiscoverBookDetail.ratingFormatter.string(from: NSNumber(value: averageRating))
    }

    var ratingsCountDisplay: String? {
        guard let ratingsCount else { return nil }
        return DiscoverBookDetail.countFormatter.string(from: NSNumber(value: ratingsCount))
    }

    func ratingAccessibilityLabel(baseKey: String) -> String? {
        guard let averageRatingDisplay else { return nil }
        let count = ratingsCount ?? 0
        let template = String(localized: String.LocalizationValue(baseKey))
        return String(format: template, averageRatingDisplay, count)
    }

    // MARK: - Formatters
    private static let ratingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()

    private static let countFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
