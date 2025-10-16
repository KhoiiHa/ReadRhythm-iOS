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
                let start = Date().addingTimeInterval(-5 * 60)
                let session = ReadingSessionEntity(startedAt: start, endedAt: Date(), durationSeconds: 5 * 60)
                context.insert(session)
                try? context.save()
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
