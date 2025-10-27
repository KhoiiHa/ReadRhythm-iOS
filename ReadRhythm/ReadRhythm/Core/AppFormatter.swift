//
//  AppFormatter.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 27.10.25.
//

import Foundation

/// Zentraler Formatter-Service für Datum, Zeit und Text-Lokalisierung.
/// Vermeidet wiederholte `DateFormatter`-Erstellung auf dem MainActor.
@MainActor
enum AppFormatter {

    // MARK: - Cached Formatters

    /// Zeigt z. B. „Dienstag“ oder „Tuesday“ je nach Locale.
    static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("EEEE")
        return f
    }()

    /// Zeigt z. B. „27. Okt 2025“ oder „Oct 27, 2025“.
    static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.dateStyle = .medium
        return f
    }()

    /// Zeigt z. B. "21:34" je nach Locale.
    static let timeShortFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    // MARK: - History / Stats Helpers

    /// Formatiert eine History-Zeile („12 Minuten gelesen am Dienstag“).
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

    /// Accessibility-freundliche Variante mit Datum.
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
