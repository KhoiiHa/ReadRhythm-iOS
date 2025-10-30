import Foundation

/// Leichtgewichtiges Modell für Remote-Buchdetails (Google Books).
/// Enthält nur lesbare Felder – kein Persistenz-State.
struct DiscoverBookDetail: Identifiable, Hashable {
    let remote: RemoteBook

    init(remote: RemoteBook) {
        self.remote = remote
    }

    init(from remote: RemoteBook) {
        self.init(remote: remote)
    }

    var id: String { remote.id }
    var title: String { remote.title }
    var subtitle: String? { remote.subtitle }
    var authors: [String] { remote.authors }
    var publisher: String? { remote.publisher }
    var publishedDate: String? { remote.publishedDate }
    var pageCount: Int? { remote.pageCount }
    var categories: [String] { remote.categories }
    var description: String? { remote.description }
    var thumbnailURL: URL? { remote.thumbnailURL }
    var previewLink: URL? { remote.previewLink }
    var infoLink: URL? { remote.infoLink }
    var languageCode: String? { remote.language }
    var averageRating: Double? { remote.averageRating }
    var ratingsCount: Int? { remote.ratingsCount }

    var authorsDisplay: String {
        remote.authorsDisplay
    }

    /// Versucht aus dem veröffentlichten Datum eine Jahreszahl zu extrahieren.
    var publishedYear: String? {
        guard let raw = publishedDate?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }

        if raw.count >= 4 {
            let prefix = raw.prefix(4)
            if prefix.allSatisfy({ $0.isNumber }) {
                return String(prefix)
            }
        }
        return raw
    }

    /// Sprachbezeichnung basierend auf dem BCP-47-Code.
    var languageDisplay: String? {
        guard let code = languageCode?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty else {
            return nil
        }

        let normalized = code.lowercased()
        if let localized = Locale.current.localizedString(forIdentifier: normalized) ??
            Locale.current.localizedString(forLanguageCode: normalized) {
            return localized.capitalized(with: Locale.current)
        }
        return code.uppercased()
    }

    /// Formatiert die Seitenanzahl.
    func pagesDisplay(localizedFormat: String) -> String? {
        guard let pages = pageCount else { return nil }
        return String(format: localizedFormat, pages)
    }

    /// Link, der bevorzugt das Preview nutzt, sonst InfoLink.
    var externalURL: URL? {
        previewLink ?? infoLink
    }

    /// Formatiert den Durchschnittsrating-String (z. B. "4,5").
    var averageRatingDisplay: String? {
        guard let rating = averageRating else { return nil }
        return DiscoverBookDetail.ratingFormatter.string(from: NSNumber(value: rating))
    }

    /// Gibt einen lokalisierten Text für die Anzahl an Bewertungen zurück.
    func ratingsCountDisplay(oneKey: String, manyKey: String) -> String? {
        guard let count = ratingsCount else { return nil }
        if count == 1 {
            return String(localized: String.LocalizationValue(oneKey))
        } else {
            return String(format: String(localized: String.LocalizationValue(manyKey)), count)
        }
    }

    private static let ratingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()
}
