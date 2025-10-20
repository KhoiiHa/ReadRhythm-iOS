//
//  ProfileViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//
import Foundation
import SwiftData

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var monthMinutes: Int = 0
    @Published var monthSessions: Int = 0
    @Published var avgPerDay: Double = 0
    @Published var currentStreak: Int = 0
    @Published var bestWeekdayIndex: Int? = nil // 0=So ... 6=Sa
    @Published var bestWeekdayMinutes: Int = 0

    private let context: ModelContext
    private let stats: StatsService

    init(context: ModelContext, statsService: StatsService = .shared) {
        self.context = context
        self.stats = statsService
        reload()
    }

    func reload() {
        let cal = Calendar.current
        let month = cal.dateInterval(of: .month, for: .now)!
        monthMinutes = stats.totalMinutes(from: month.start, to: month.end, in: context)
        monthSessions = stats.totalSessions(from: month.start, to: month.end, in: context)
        avgPerDay = stats.averageMinutesPerDay(from: month.start, to: month.end, in: context)
        currentStreak = Self.computeStreak(using: stats, context: context)

        let byWeekday = stats.minutesByWeekday(from: month.start, to: month.end, in: context)
        if let best = byWeekday.max(by: { $0.value < $1.value }) {
            bestWeekdayIndex = best.key
            bestWeekdayMinutes = best.value
        } else {
            bestWeekdayIndex = nil
            bestWeekdayMinutes = 0
        }
    }

    static func computeStreak(using service: StatsService, context: ModelContext) -> Int {
        let cal = Calendar.current
        var streak = 0
        for offset in 0..<60 {
            guard let date = cal.date(byAdding: .day, value: -offset, to: .now) else { continue }
            let minutes = service.minutes(on: date, in: context)
            if minutes > 0 { streak += 1 } else { break }
        }
        return streak
    }

    // i18n-Helfer
    func weekdayLabel(for index: Int) -> String {
        let symbols = Calendar.current.weekdaySymbols // So..Sa (lokalisiert vom System)
        let i = (index % 7 + 7) % 7
        return symbols[i]
    }
}
