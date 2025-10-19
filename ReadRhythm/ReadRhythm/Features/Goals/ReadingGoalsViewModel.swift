//
//  ReadingGoalsViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import Foundation
import SwiftData

@MainActor
final class ReadingGoalsViewModel: ObservableObject {
    @Published var activeGoal: ReadingGoalEntity?
    @Published var progress: Double = 0.0
    @Published var streakCount: Int = 0
    @Published var totalMinutes: Int = 0

    private let context: ModelContext
    private let statsService: StatsService

    init(context: ModelContext, statsService: StatsService) {
        self.context = context
        self.statsService = statsService
        loadActiveGoal()
        calculateProgress()
    }

    func loadActiveGoal() {
        if let goal = try? context.fetch(ReadingGoalEntity.activeGoalFetchDescriptor).first {
            self.activeGoal = goal
        } else {
            self.activeGoal = nil
        }
    }

    func calculateProgress() {
        guard let goal = activeGoal else { return }
        let periodRange = Self.dateRange(for: goal.period)

        // Hier: neue Extension-APIs + korrekter context
        let minutes = statsService.totalMinutes(from: periodRange.start, to: periodRange.end, in: context)
        self.totalMinutes = minutes
        self.progress = min(Double(minutes) / Double(max(goal.targetMinutes, 1)), 1.0)

        self.streakCount = Self.computeStreak(using: statsService, context: context)
    }

    static func dateRange(for period: GoalPeriod) -> (start: Date, end: Date) {
        let cal = Calendar.current
        let now = Date()
        switch period {
        case .daily:
            let start = cal.startOfDay(for: now)
            let end = cal.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
        case .weekly:
            let week = cal.dateInterval(of: .weekOfYear, for: now)!
            return (week.start, week.end)
        case .monthly:
            let month = cal.dateInterval(of: .month, for: now)!
            return (month.start, month.end)
        }
    }

    /// Vereinfachte Streak-Logik: zähle rückwärts Tage mit >0 Minuten
    static func computeStreak(using service: StatsService, context: ModelContext) -> Int {
        let cal = Calendar.current
        var streak = 0
        for offset in 0..<30 {
            guard let date = cal.date(byAdding: .day, value: -offset, to: .now) else { continue }
            let minutes = service.minutes(on: date, in: context)
            if minutes > 0 { streak += 1 } else { break }
        }
        return streak
    }
}
