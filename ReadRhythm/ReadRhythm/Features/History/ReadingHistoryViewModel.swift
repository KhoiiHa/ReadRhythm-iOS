//
//  ReadingHistoryViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import Foundation
import SwiftData

struct ReadingHistoryItem: Identifiable {
    let id: UUID
    let date: Date
    let minutes: Int
    let bookTitle: String
}

@MainActor
final class ReadingHistoryViewModel: ObservableObject {
    @Published var sections: [(date: Date, items: [ReadingHistoryItem])] = []

    private let context: ModelContext
    private let cal = Calendar.current

    init(context: ModelContext) {
        self.context = context
        reload()
    }

    func reload(range: DateInterval? = nil) {
        let pred: Predicate<ReadingSessionEntity> = {
            if let r = range {
                return #Predicate<ReadingSessionEntity> { s in
                    s.date >= r.start && s.date < r.end
                }
            } else {
                // Alles
                return #Predicate<ReadingSessionEntity> { _ in true }
            }
        }()

        var fd = FetchDescriptor<ReadingSessionEntity>(predicate: pred)
        fd.sortBy = [ .init(\.date, order: .reverse) ]

        do {
            let sessions = try context.fetch(fd)
            let items: [ReadingHistoryItem] = sessions.map {
                ReadingHistoryItem(
                    id: $0.id,
                    date: $0.date,
                    minutes: $0.minutes,
                    bookTitle: $0.book.title   
                )
            }

            // Gruppieren nach Tag
            let grouped = Dictionary(grouping: items) { item in
                cal.startOfDay(for: item.date)
            }
            let sortedDays = grouped.keys.sorted(by: >)
            self.sections = sortedDays.map { day in
                (date: day, items: grouped[day]!.sorted { $0.date > $1.date })
            }
        } catch {
            #if DEBUG
            print("[DEBUG] History fetch error: \(error)")
            #endif
            self.sections = []
        }
    }

    // Für Section-Header
    func dayLabel(_ date: Date) -> String {
        if cal.isDateInToday(date) { return String(localized: "history.today") }
        if cal.isDateInYesterday(date) { return String(localized: "history.yesterday") }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt.string(from: date)
    }

    func timeLabel(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .none
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
}
