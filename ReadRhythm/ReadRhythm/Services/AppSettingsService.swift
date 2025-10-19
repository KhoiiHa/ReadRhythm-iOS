//
//  AppSettingsService.swift
//  ReadRhythm
//
//  Verwaltet App-weite Nutzerpräferenzen (Theme, Sprache etc.)
//  Phase 3: Refactor/Portfolio – mit persistenter Speicherung über UserDefaults.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppSettingsService: ObservableObject {
    static let shared = AppSettingsService()

    // MARK: - Keys & Defaults
    private let defaults = UserDefaults.standard
    private enum Keys {
        static let themeMode = "settings.theme.mode"
        static let language = "settings.language"
    }

    // MARK: - Published Properties
    /// Das aktuelle App-Theme (System / Light / Dark)
    @Published var themeMode: AppThemeMode {
        didSet {
            defaults.set(themeMode.rawValue, forKey: Keys.themeMode)
            #if DEBUG
            print("[AppSettings] Theme updated → \(themeMode.rawValue)")
            #endif
        }
    }

    /// Gewählte App-Sprache (ISO-Code, z. B. „de“ oder „en“)
    @Published var preferredLanguage: String {
        didSet {
            defaults.set(preferredLanguage, forKey: Keys.language)
            #if DEBUG
            print("[AppSettings] Language updated → \(preferredLanguage)")
            #endif
        }
    }

    // MARK: - Init
    private init() {
        // Theme laden
        if let rawValue = defaults.string(forKey: Keys.themeMode),
           let mode = AppThemeMode(rawValue: rawValue) {
            self.themeMode = mode
        } else {
            self.themeMode = .system
        }

        // Sprache laden
        self.preferredLanguage = defaults.string(forKey: Keys.language) ?? Locale.current.language.languageCode?.identifier ?? "en"
    }
}
