//
//  FocusModeViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import Foundation
import SwiftData
import CoreHaptics

@MainActor
final class FocusModeViewModel: ObservableObject {
    @Published var durationMinutes: Int = 25
    @Published var remainingSeconds: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var selectedBook: BookEntity? = nil // Optional – später bindbar

    private var timer: Timer?
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        self.remainingSeconds = durationMinutes * 60
    }

    func start() {
        guard !isRunning else { return }
        remainingSeconds = durationMinutes * 60
        isRunning = true
        scheduleTimer()
    }

    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingSeconds = durationMinutes * 60
    }

    func updateDuration(_ minutes: Int) {
        durationMinutes = max(5, min(minutes, 120))
        if !isRunning {
            remainingSeconds = durationMinutes * 60
        }
    }

    func select(book: BookEntity) {
        selectedBook = book
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.tick()
            }
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            finish()
            return
        }
        remainingSeconds -= 1
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        isRunning = false

        // Session nur speichern, wenn ein Buch gewählt wurde
        guard let book = selectedBook else {
            #if DEBUG
            print("[DEBUG] FocusMode: no book selected, skipping auto-save")
            #endif
            return
        }

        let minutes = max(1, durationMinutes)

        // ⬇️ Reihenfolge: date vor minutes
        let session = ReadingSessionEntity(date: .now, minutes: minutes, book: book)
        context.insert(session)
        do {
            try context.save()
            #if DEBUG
            print("[DEBUG] FocusMode saved session: \(minutes)min for \(book.title)")
            #endif
        } catch {
            #if DEBUG
            print("[DEBUG] FocusMode save error: \(error)")
            #endif
        }
    }

    func formattedRemaining() -> String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
