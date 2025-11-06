//
//  DiscoverCategory.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 22.10.25.
//

import Foundation

/// Feste Discover-Bundles für Google Books (zielgruppenorientiert 🌸).
/// Architektur-Notiz:
/// - RawValue sind **i18n-Keys** (keine Hardcodes im UI).
/// - `displayName` liefert die lokalisierte Anzeige.
/// - `query` ist die API-Suchsyntax für Google Books.
/// - `systemImage` kann im UI für Icon-Buttons/Chips genutzt werden.
enum DiscoverCategory: String, CaseIterable, Identifiable {
    // RawValue = i18n-Key
    case mindfulness      = "discover.category.mindfulness"
    case selfHelp         = "discover.category.self_help"
    case philosophy       = "discover.category.philosophy"
    case fictionRomance   = "discover.category.fiction_romance"
    case creativity       = "discover.category.creativity"
    case wellness         = "discover.category.wellness"
    case psychology       = "discover.category.psychology"

    var id: String { rawValue }

    /// Lokalisierter Anzeigename (aus .strings). Fallback = i18n-Key.
    var displayName: String {
        let text = NSLocalizedString(rawValue, comment: "Discover category title")
        return text.isEmpty ? rawValue : text
    }

    /// Query für Google Books API (wird direkt an `BookSearchRepository` gegeben).
    var query: String {
        switch self {
        case .mindfulness:
            // Breiter gefasst: enthält Mindfulness, Meditation, Stressabbau
            return #"subject:"mindfulness" OR subject:"meditation" OR mindfulness OR meditation OR "stress relief" OR "inner peace""#
        case .selfHelp:
            // Persönlichkeitsentwicklung, Motivation, Selbsthilfe
            return #"self-help OR personal growth OR motivation OR "self improvement" OR habits OR inspiration"#
        case .philosophy:
            // Lebenskunst, Ethik, Stoizismus
            return #"philosophy OR stoicism OR ethics OR spirituality OR wisdom OR "life philosophy""#
        case .fictionRomance:
            // Belletristik & Romantik
            return #"fiction OR romance OR love story OR novel OR literature"#
        case .creativity:
            // Kreativität, Kunst, Schreiben
            return #"art OR creativity OR design OR writing OR imagination OR "creative process""#
        case .wellness:
            // Gesundheit, Wohlbefinden, Körper & Geist
            return #"health OR wellness OR fitness OR nutrition OR mindfulness OR "body mind spirit""#
        case .psychology:
            // Psychologie, Emotionen, mentales Wohlbefinden
            return #"psychology OR mental health OR wellbeing OR "emotional intelligence" OR "self awareness""#
        }
    }

    /// SF Symbol für UI-Buttons/Chips (visuell klar + thematisch passend zur Zielgruppe).
    var systemImage: String {
        switch self {
        case .mindfulness:
            // ruhig, Balance, Achtsamkeit
            return "leaf"
        case .selfHelp:
            // Selbstentwicklung / Wachstum / innere Arbeit
            return "figure.mind.and.body"
        case .philosophy:
            // Nachdenken, Lebenskunst, Weisheit
            return "book.closed"
        case .fictionRomance:
            // Emotionale Geschichten, Nähe, Beziehungen
            return "book.heart"
        case .creativity:
            // Ausdruck, Gestaltung, eigene Stimme
            return "paintpalette"
        case .wellness:
            // Wohlbefinden, Self-Care, Für-sich-sorgen
            return "heart.text.square"
        case .psychology:
            // Kopf & Gefühle verstehen
            return "brain.head.profile"
        }
    }

    /// Optionale feste Reihenfolge für UI-Listen (anstelle von CaseIterable.default).
    static var ordered: [DiscoverCategory] {
        [.mindfulness, .selfHelp, .philosophy, .fictionRomance, .creativity, .wellness, .psychology]
    }
}
