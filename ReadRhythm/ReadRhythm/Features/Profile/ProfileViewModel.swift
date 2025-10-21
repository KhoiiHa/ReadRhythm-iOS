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

    @Published var dailyStats: [DailyStatDTO] = []
    @Published var mode: InsightsMode = .combined

    enum InsightsMode: String, CaseIterable, Identifiable {
        case reading, listening, combined
        var id: String { rawValue }

        var i18nKey: String {
            switch self {
            case .reading: return "insights.mode.reading"
            case .listening: return "insights.mode.listening"
            case .combined: return "insights.mode.combined"
            }
        }
    }

    private let context: ModelContext
    private let statsService: StatsService

    init(context: ModelContext, statsService: StatsService = .shared) {
        self.context = context
        self.statsService = statsService
        reload()
    }

    func reload() {
        let cal = Calendar.current
        let month = cal.dateInterval(of: .month, for: .now)!
        monthMinutes = statsService.totalMinutes(from: month.start, to: month.end, in: context)
        monthSessions = statsService.totalSessions(from: month.start, to: month.end, in: context)
        avgPerDay = statsService.averageMinutesPerDay(from: month.start, to: month.end, in: context)
        currentStreak = Self.computeStreak(using: statsService, context: context)

        let byWeekday = statsService.minutesByWeekday(from: month.start, to: month.end, in: context)
        if let best = byWeekday.max(by: { $0.value < $1.value }) {
            bestWeekdayIndex = best.key
            bestWeekdayMinutes = best.value
        } else {
            bestWeekdayIndex = nil
            bestWeekdayMinutes = 0
        }

        // Fetch last 30 days for Insights Charts
        dailyStats = statsService.fetchDailyStats(context: context, days: 30)
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

    var averageMinutes: Double {
        guard !dailyStats.isEmpty else { return 0 }
        let total = dailyStats.reduce(0) { $0 + value(for: $1) }
        return Double(total) / Double(dailyStats.count)
    }

    var titleKey: String {
        switch mode {
        case .reading: return "insights.title.reading"
        case .listening: return "insights.title.listening"
        case .combined: return "insights.title.combined"
        }
    }

    func value(for day: DailyStatDTO) -> Int {
        switch mode {
        case .reading: return day.readingMinutes
        case .listening: return day.listeningMinutes
        case .combined: return day.readingMinutes + day.listeningMinutes
        }
    }
}
