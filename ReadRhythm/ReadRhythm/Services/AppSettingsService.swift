//
//  AppSettingsService.swift
//  ReadRhythm
//
//  Verwaltet App-weite Einstellungen mit UserDefaults.
//  Ziel: Speichern von Sprache, Theme und anderen Nutzerpräferenzen.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppSettingsService: ObservableObject {
    static let shared = AppSettingsService()

    private let defaults = UserDefaults.standard
    private let themeKey = "settings.theme.mode"
    private let languageKey = "preferredLanguage"

    // MARK: - Published Settings
    @Published var themeMode: AppThemeMode {
        didSet {
            defaults.set(themeMode.rawValue, forKey: themeKey)
            #if DEBUG
            print("[AppSettings] Theme updated → \(themeMode.rawValue)")
            #endif
        }
    }

    @Published var preferredLanguage: String {
        didSet {
            defaults.set(preferredLanguage, forKey: languageKey)
        }
    }

    // MARK: - Init
    private init() {
        // Theme
        if let raw = defaults.string(forKey: themeKey),
           let mode = AppThemeMode(rawValue: raw) {
            self.themeMode = mode
        } else {
            self.themeMode = .system
        }

        // Sprache
        self.preferredLanguage = defaults.string(forKey: languageKey) ?? "de"
    }
}
