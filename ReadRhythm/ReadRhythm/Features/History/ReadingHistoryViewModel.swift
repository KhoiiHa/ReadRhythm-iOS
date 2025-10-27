// Kontext: Dieses ViewModel kuratiert die Lese- und Hörhistorie für den History-Screen.
// Warum: Die Liste braucht verständliche Strings, Icons und Sortierung statt roher Session-Entities.
// Wie: Wir aggregieren Daten aus SwiftData, formatieren sie via AppFormatter und liefern UI-fertige Modelle.
import Foundation
import SwiftData
import SwiftUI

/// Kontext → Warum → Wie:
/// Dieser ViewModel-Flow bereitet Lesesessions/Hörsessions für die History-Liste auf.
/// Warum: Die View selbst soll keine Format-Strings zusammenbauen (z. B. "12 Minuten gehört am Dienstag")
///        und keine DateFormatter pro Zelle erzeugen. Das passiert hier zentral und nutzt AppFormatter.
/// Wie: Wir mappen ReadingSessionEntity → ReadingHistoryItem (Rohdaten) → HistoryRowDisplayData
///      (formatierte Strings + Icon + A11y-Label), sodass die Row-View nur noch rendert.
struct ReadingHistoryItem: Identifiable {
    let id: UUID
    let date: Date
    let minutes: Int
    let bookTitle: String
    let medium: String
}

/// Fertig formatierte Darstellung für eine einzelne History-Zeile.
/// Wird direkt von der Row-View benutzt.
struct HistoryRowDisplayData: Identifiable {
    let id: UUID

    /// Sichtbarer Haupttext, z. B. "12 Minuten gelesen"
    let titleText: String

    /// Sekundärtext, z. B. Buchtitel oder "Unbekanntes Buch"
    let subtitleText: String

    /// Zeitstempel (z. B. "21:34"), bereits formatiert
    let timeText: String

    /// SF Symbol Name für das Medium ("book" vs "headphones")
    let iconSystemName: String

    /// Vollständige VoiceOver-Beschreibung der Zeile
    let accessibilityLabel: String
}

@MainActor
final class ReadingHistoryViewModel: ObservableObject {
    @Published var sections: [(date: Date, items: [ReadingHistoryItem])] = []
    /// Baut die für die UI gedachte Darstellung (Strings, Icon, A11y) für eine einzelne Session.
    func makeDisplayData(for item: ReadingHistoryItem) -> HistoryRowDisplayData {
        // Sichtbarer Titeltext (z. B. "12 Minuten gehört am Dienstag")
        let mainLine = AppFormatter.historyRowText(
            minutes: item.minutes,
            medium: item.medium,
            date: item.date
        )

        // Unterzeile = Buchtitel
        let subtitle = item.bookTitle

        // Uhrzeit formatiert über gecachten Formatter
        let timeString = AppFormatter.timeShortFormatter.string(from: item.date)

        // Icon abhängig vom Medium
        let iconName = (item.medium == "listening") ? "headphones" : "book"

        // A11y-Label: ausführlicher inklusive Datum
        let a11y = AppFormatter.historyAccessibilityLabel(
            minutes: item.minutes,
            medium: item.medium,
            date: item.date
        ) + ", " + subtitle

        return HistoryRowDisplayData(
            id: item.id,
            titleText: mainLine,
            subtitleText: subtitle,
            timeText: timeString,
            iconSystemName: iconName,
            accessibilityLabel: a11y
        )
    }

    /// Liefert fertige Anzeige-Objekte gruppiert pro Kalendertag.
    /// Views können direkt über diese Struktur iterieren.
    func displaySections() -> [(date: Date, rows: [HistoryRowDisplayData])] {
        sections.map { section in
            let rows = section.items.map { makeDisplayData(for: $0) }
            return (date: section.date, rows: rows)
        }
    }

    private let context: ModelContext
    private let cal = Calendar.current

    init(context: ModelContext) {
        self.context = context
        reload()
    }

    func reload(range: DateInterval? = nil) {
        let pred: Predicate<ReadingSessionEntity> = {
            if let r = range {
                return #Predicate<ReadingSessionEntity> { s in
                    s.date >= r.start && s.date < r.end
                }
            } else {
                // Alles
                return #Predicate<ReadingSessionEntity> { _ in true }
            }
        }()

        var fd = FetchDescriptor<ReadingSessionEntity>(predicate: pred)
        fd.sortBy = [ .init(\.date, order: .reverse) ]

        do {
            let sessions = try context.fetch(fd)
            let items: [ReadingHistoryItem] = sessions.map { s in
                let title = s.book?.title ?? String(localized: "history.unknownBook")
                return ReadingHistoryItem(
                    id: s.id,
                    date: s.date,
                    minutes: s.minutes,
                    bookTitle: title,
                    medium: s.medium
                )
            }

            // Gruppieren nach Tag
            let grouped = Dictionary(grouping: items) { item in
                cal.startOfDay(for: item.date)
            }
            let sortedDays = grouped.keys.sorted(by: >)
            self.sections = sortedDays.map { day in
                (date: day, items: grouped[day]!.sorted { $0.date > $1.date })
            }
        } catch {
            #if DEBUG
            DebugLogger.log("❌ [History] fetch error: \(error)")
            #endif
            self.sections = []
        }
    }

    // Für Section-Header
    func dayLabel(_ date: Date) -> String {
        if cal.isDateInToday(date) {
            return String(localized: "history.today")
        }
        if cal.isDateInYesterday(date) {
            return String(localized: "history.yesterday")
        }
        // Fallback: lokalisierte, mittel-lange Datumsdarstellung (z. B. "27. Okt. 2025")
        return AppFormatter.shortDateFormatter.string(from: date)
    }

    func timeLabel(_ date: Date) -> String {
        return AppFormatter.timeShortFormatter.string(from: date)
    }
}
