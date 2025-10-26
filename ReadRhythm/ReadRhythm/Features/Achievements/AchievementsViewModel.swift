//
//  AchievementsViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import Foundation
import SwiftData
import SwiftUI


struct Achievement: Identifiable {
    let id: String
    let titleKey: String         // i18n-Schlüssel
    let subtitleKey: String      // i18n-Schlüssel
    let systemImage: String
    var unlocked: Bool
    let highlightValue: String?  // z.B. "7 Tage", "500 Min"
}

@MainActor
final class AchievementsViewModel: ObservableObject {
    @Published var items: [Achievement] = []

    private let context: ModelContext
    private let stats: StatsService

    init(context: ModelContext, statsService: StatsService? = nil) {
        self.context = context
        // Fallback auf den globalen Service erst im MainActor-Init,
        // nicht als Default-Argument. Das beruhigt Swift 6.
        self.stats = statsService ?? StatsService.shared
        reload()
    }

    func reload() {
        #if DEBUG
        DebugLogger.log("[Achievements] reload")
        #endif
        let cal = Calendar.current
        let month = cal.dateInterval(of: .month, for: .now)!
        let week  = cal.dateInterval(of: .weekOfYear, for: .now)!

        let minutesMonth = stats.totalMinutes(from: month.start, to: month.end, in: context)
        let minutesWeek  = stats.totalMinutes(from: week.start, to: week.end, in: context)
        let sessionsWeek = stats.totalSessions(from: week.start, to: week.end, in: context)
        let streak       = Self.currentStreak(using: stats, context: context, daysBack: 60)

        // Regeln (einfach, erweiterbar)
        var tmp: [Achievement] = []

        tmp.append(Achievement(
            id: "week.150min",
            titleKey: "achv.week.150.title",
            subtitleKey: "achv.week.150.subtitle",
            systemImage: "timer",
            unlocked: minutesWeek >= 150,
            highlightValue: "\(minutesWeek) " + NSLocalizedString("goals.metric.minutes", comment: "")
        ))

        tmp.append(Achievement(
            id: "month.500min",
            titleKey: "achv.month.500.title",
            subtitleKey: "achv.month.500.subtitle",
            systemImage: "calendar",
            unlocked: minutesMonth >= 500,
            highlightValue: "\(minutesMonth) " + NSLocalizedString("goals.metric.minutes", comment: "")
        ))

        tmp.append(Achievement(
            id: "streak.7",
            titleKey: "achv.streak.7.title",
            subtitleKey: "achv.streak.7.subtitle",
            systemImage: "flame.fill",
            unlocked: streak >= 7,
            highlightValue: "\(streak) " + NSLocalizedString("goals.streak.days", comment: "")
        ))

        tmp.append(Achievement(
            id: "week.5sessions",
            titleKey: "achv.week.5sessions.title",
            subtitleKey: "achv.week.5sessions.subtitle",
            systemImage: "book.fill",
            unlocked: sessionsWeek >= 5,
            highlightValue: "\(sessionsWeek)"
        ))

        self.items = tmp
    }

    // Vereinfachte Streak-Logik: zähle rückwärts Tage mit >0 Minuten
    @MainActor
    static func currentStreak(using service: StatsService, context: ModelContext, daysBack: Int) -> Int {
        let cal = Calendar.current
        var streak = 0
        for offset in 0..<daysBack {
            guard let date = cal.date(byAdding: .day, value: -offset, to: .now) else { break }
            let m = service.minutes(on: date, in: context)
            if m > 0 { streak += 1 } else { break }
        }
        return streak
    }
}
