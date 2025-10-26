//
//  ReadingGoalsViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class ReadingGoalsViewModel: ObservableObject {
    @Published var activeGoal: ReadingGoalEntity?
    @Published var progress: Double = 0.0
    @Published var streakCount: Int = 0
    @Published var totalMinutes: Int = 0

    // Edit Sheet State
    @Published var isEditing: Bool = false
    @Published var editTargetMinutes: Int = 60

    private let context: ModelContext
    private let statsService: StatsService

    init(context: ModelContext, statsService: StatsService) {
        self.context = context
        self.statsService = statsService
        loadActiveGoal()
        calculateProgress()
    }

    // MARK: - Editing API (used by Edit-Goal Sheet)

    /// Prefills the edit value from the active goal and opens the sheet.
    func startEditing() {
        if let goal = activeGoal {
            editTargetMinutes = max(5, goal.targetMinutes)
        } else {
            // sensible default when no goal exists yet
            editTargetMinutes = max(5, 60)
        }
        isEditing = true
        #if DEBUG
        DebugLogger.log("[Goals] startEditing – prefill target=\(editTargetMinutes)")
        #endif
    }

    /// Clamps the value to a sane range for UI controls (5…600 minutes)
    func validateTarget(_ value: Int) -> Int {
        return min(max(value, 5), 600)
    }

    /// Persists the new target on the active goal and recomputes progress.
    /// Returns true on success; false if no active goal is available.
    @discardableResult
    func saveGoal(targetMinutes: Int, period: GoalPeriod? = nil) -> Bool {
        guard let goal = activeGoal else {
            #if DEBUG
            DebugLogger.log("[Goals] saveGoal – no active goal to update")
            #endif
            return false
        }
        let newValue = validateTarget(targetMinutes)
        goal.targetMinutes = newValue
        if let p = period { goal.period = p }
        do {
            try context.save()
            // reflect in UI
            isEditing = false
            calculateProgress()
            #if DEBUG
            DebugLogger.log("[Goals] saveGoal – saved target=\(newValue), period=\(goal.period)")
            #endif
            return true
        } catch {
            #if DEBUG
            DebugLogger.log("⚠️ [Goals] saveGoal error: \(error)")
            #endif
            return false
        }
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
        #if DEBUG
        DebugLogger.log("[Goals] calculateProgress for period=\(goal.period) target=\(goal.targetMinutes)")
        #endif
        let periodRange = Self.dateRange(for: goal.period)

        // Hier: neue Extension-APIs + korrekter context
        let minutes = statsService.totalMinutes(from: periodRange.start, to: periodRange.end, in: context)
        self.totalMinutes = minutes
        self.progress = min(Double(minutes) / Double(max(goal.targetMinutes, 1)), 1.0)

        self.streakCount = Self.computeStreak(using: statsService, context: context)
    }

    @MainActor
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
    @MainActor
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
    /// Helper for UI previews / labels
    func progressPercentageString() -> String {
        let pct = Int((progress * 100).rounded())
        return "\(pct)%"
    }
    /// Text for "X / Y min" style progress label in the UI.
    func progressSummaryString() -> String {
        guard let goal = activeGoal else { return "\(totalMinutes) min" }
        return "\(totalMinutes) / \(goal.targetMinutes) min"
    }
}
