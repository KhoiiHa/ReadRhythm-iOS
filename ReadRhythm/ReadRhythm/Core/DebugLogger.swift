//
//  DebugLogger.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import Foundation

/// Einfacher globaler Debug-Logger für das Projekt.
/// Aktiv nur in DEBUG-Builds.
enum DebugLogger {
    static func log(_ message: String) {
        #if DEBUG
        print("[DEBUG] \(message)")
        #endif
    }
}
