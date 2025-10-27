
//  AppLanguage.swift
//  ReadRhythm
//
//  Kontext → Warum → Wie
//  Kontext: Zentraler Zugriff auf die aktuelle Nutzer-Lokalisierung.
//  Warum: Wir formatieren Datum/Zeit/VoiceOver-Texte lokalisiert (siehe AppFormatter).
//         Für Debug-Zwecke wollen wir klar abfragen können, welche Sprache aktiv ist.
//  Wie: Kleine statische Helper, kein globaler State.
//

import Foundation

enum AppLanguage {

    /// Aktueller BCP-47 Sprachcode, z. B. "de-DE" oder "en-US".
    static var currentLanguageCode: String {
        Locale.autoupdatingCurrent.identifier
    }

    /// Kurzer Sprachcode (z. B. "de" oder "en"), falls wir ihn in Analytics / Debug-Logs brauchen.
    static var shortCode: String {
        Locale.autoupdatingCurrent.language.languageCode?.identifier ?? "unknown"
    }
}
