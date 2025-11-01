//
//  AppThemeMode.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 18.10.25.
//

import Foundation
import SwiftUI

enum AppThemeMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var localizedTitleKey: LocalizedStringKey {
        switch self {
        case .system: "settings.theme.system"
        case .light:  "settings.theme.light"
        case .dark:   "settings.theme.dark"
        }
    }

    /// Mapping fürs Root: nil = System folgen
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }
}

// MARK: - Bridge to AppAppearance
extension AppThemeMode {
    init(_ appearance: AppAppearance) {
        switch appearance {
        case .system: self = .system
        case .light:  self = .light
        case .dark:   self = .dark
        }
    }

    var asAppearance: AppAppearance {
        switch self {
        case .system: .system
        case .light:  .light
        case .dark:   .dark
        }
    }
}
