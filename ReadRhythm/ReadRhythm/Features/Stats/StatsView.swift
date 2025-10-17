//
//  StatsView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var context
    @State private var totalSeconds: TimeInterval = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("Stats – Platzhalter")
            Text("Gesamtlesezeit: \(Int(totalSeconds / 60)) min")
                .accessibilityIdentifier("stats.totalReadingTime")
#if DEBUG
            Button("+5 min Session (DEBUG)") {
                // Finde vorhandenes Buch oder erzeuge ein Debug-Buch
                let bookFetch = FetchDescriptor<BookEntity>()
                let existingBook = (try? context.fetch(bookFetch))?.first
                let book = existingBook ?? {
                    let b = BookEntity(title: "Debug Book", author: "")
                    context.insert(b)
                    return b
                }()

                // Neue Session im neuen Schema: date + minutes + book
                let session = ReadingSessionEntity(date: Date(), minutes: 5, book: book)
                context.insert(session)
                try? context.save()

                // Aktualisiere Anzeige
                totalSeconds = StatsService.shared.totalReadingTime(context: context)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("stats.debug.add5")
#endif
        }
        .padding()
        .onAppear {
            totalSeconds = StatsService.shared.totalReadingTime(context: context)
        }
        .accessibilityIdentifier("stats.view")
    }
}
