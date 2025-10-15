//
//  AppSettingsService.swift
//  ReadRhythm
//
//  Verwaltet App-weite Einstellungen mit UserDefaults.
//  Ziel: Speichern von Sprache, Theme und anderen Nutzerpräferenzen.
//

import Foundation

final class AppSettingsService {
    static let shared = AppSettingsService()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let preferredLanguage = "preferredLanguage"
        static let darkModeEnabled = "darkModeEnabled"
    }

    private init() {}

    var preferredLanguage: String {
        get { defaults.string(forKey: Keys.preferredLanguage) ?? "de" }
        set { defaults.set(newValue, forKey: Keys.preferredLanguage) }
    }

    var darkModeEnabled: Bool {
        get { defaults.bool(forKey: Keys.darkModeEnabled) }
        set { defaults.set(newValue, forKey: Keys.darkModeEnabled) }
    }
}
