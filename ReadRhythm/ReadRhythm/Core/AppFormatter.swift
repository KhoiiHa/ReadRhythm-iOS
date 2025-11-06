// MARK: - Formatter Hub / Formatter-Hub
// Kontext: Zentralisiert lokalisierte Formatierung / Context: Centralizes localized formatting logic.
// Warum: Wiederverwendung verbessert Performance / Why: Reuse boosts performance and consistency.
// Wie: Statische Formatter + Utilities für Views & Services / How: Static formatters plus utilities for views and services.
import Foundation

/// Zentraler Formatter-Service für Datum, Zeit und Text /
/// Central formatter service for date, time, and text localization.
/// Vermeidet wiederholte `DateFormatter`-Erstellung /
/// Avoids repeated `DateFormatter` instantiation on the main actor.
@MainActor
enum AppFormatter {

    // MARK: - Cached Formatters

    /// Liefert den Wochentag lokalisiert / Returns localized weekday names
    static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("EEEE")
        return f
    }()

    /// Liefert ein mittleres Datum / Produces medium-style localized dates
    static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.dateStyle = .medium
        return f
    }()

    /// Formatiert kurze Uhrzeiten / Formats short time strings
    static let timeShortFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    /// Formatiert Minutenwerte lokalisiert / Formats minute values localized
    static let minutesFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .short
        f.allowedUnits = [.minute]
        f.zeroFormattingBehavior = [.default]
        return f
    }()

    /// Liefert relative Datumsangaben / Provides relative date strings
    static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.locale = .autoupdatingCurrent
        f.unitsStyle = .full
        return f
    }()

    /// Hilfsfunktion für Minutenanzeige / Helper producing localized minute strings
    static func minutesString(_ minutes: Int) -> String {
        let comps = DateComponents(minute: minutes)
        return minutesFormatter.string(from: comps) ?? "\(minutes)"
    }

    // MARK: - History / Stats Helpers

    /// Formatiert History-Zeilen / Formats history row titles
    static func historyRowText(minutes: Int, medium: String, date: Date) -> String {
        let day = weekdayFormatter.string(from: date)
        switch medium {
        case "listening":
            // "%d Minuten gehört am %@"
            let template = NSLocalizedString(
                "history.row.listening",
                comment: "History row main line for listening sessions: <minutes> Minuten gehört am <weekday>"
            )
            return String(format: template, minutes, day)
        default:
            // "%d Minuten gelesen am %@"
            let template = NSLocalizedString(
                "history.row.reading",
                comment: "History row main line for reading sessions: <minutes> Minuten gelesen am <weekday>"
            )
            return String(format: template, minutes, day)
        }
    }

    /// Accessibility-freundliche Variante mit Datum /
    /// Accessibility-friendly variant including the date
    static func historyAccessibilityLabel(minutes: Int, medium: String, date: Date) -> String {
        let fullDate = shortDateFormatter.string(from: date)
        switch medium {
        case "listening":
            // "%d Minuten gehört am %@"
            let template = NSLocalizedString(
                "accessibility.history.listening",
                comment: "VoiceOver label for a listening session in history: <minutes> Minuten gehört am <full date>"
            )
            return String(format: template, minutes, fullDate)
        default:
            // "%d Minuten gelesen am %@"
            let template = NSLocalizedString(
                "accessibility.history.reading",
                comment: "VoiceOver label for a reading session in history: <minutes> Minuten gelesen am <full date>"
            )
            return String(format: template, minutes, fullDate)
        }
    }
}
