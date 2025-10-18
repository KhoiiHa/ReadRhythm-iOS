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
