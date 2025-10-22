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

    /// Lokaliserter Anzeigename (aus .strings). Fallback = i18n-Key.
    var displayName: String {
        let text = NSLocalizedString(rawValue, comment: "Discover category title")
        return text.isEmpty ? rawValue : text
    }

    /// Query für Google Books API (wird direkt an `BookSearchRepository` gegeben).
    var query: String {
        switch self {
        case .mindfulness:    return "subject:mindfulness OR subject:meditation"
        case .selfHelp:       return "subject:self-help OR subject:personal+growth"
        case .philosophy:     return "subject:philosophy OR subject:spirituality"
        case .fictionRomance: return "subject:fiction OR subject:romance"
        case .creativity:     return "subject:art OR subject:creativity"
        case .wellness:       return "subject:health OR subject:wellness"
        case .psychology:     return "subject:psychology"
        }
    }

    /// SF Symbol für UI-Buttons/Chips (Portfolio-polish, optional).
    var systemImage: String {
        switch self {
        case .mindfulness:    return "leaf"
        case .selfHelp:       return "sparkles"
        case .philosophy:     return "book.closed"
        case .fictionRomance: return "heart.text.square"
        case .creativity:     return "paintpalette"
        case .wellness:       return "cross.case" // alternativ: "heart"
        case .psychology:     return "brain.head.profile"
        }
    }

    /// Optionale feste Reihenfolge für UI-Listen (anstelle von CaseIterable.default).
    static var ordered: [DiscoverCategory] {
        [.mindfulness, .selfHelp, .philosophy, .fictionRomance, .creativity, .wellness, .psychology]
    }
}
