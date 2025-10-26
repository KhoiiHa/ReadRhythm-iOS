//
//  FocusModeViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import Foundation
import SwiftData
import CoreHaptics
import SwiftUI


@MainActor
final class FocusModeViewModel: ObservableObject {
    // MARK: - Published UI State
    @Published var durationMinutes: Int = 25          // user-selected focus length in minutes
    @Published var remainingSeconds: Int = 25 * 60     // countdown timer state
    @Published var isRunning: Bool = false             // whether the timer is actively ticking
    @Published var selectedBook: BookEntity? = nil     // the book this focus session belongs to

    private var timer: Timer?

    // Repository responsible for persisting reading sessions
    private let sessionRepository: SessionRepository

    // Internal flag to prevent duplicate save on finish()
    private var didFinishAndSave: Bool = false

    init(sessionRepository: SessionRepository) {
        self.sessionRepository = sessionRepository
        self.remainingSeconds = durationMinutes * 60
    }

    func start() {
        guard !isRunning else { return }
        didFinishAndSave = false
        remainingSeconds = durationMinutes * 60
        isRunning = true
        scheduleTimer()
    }

    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func resume() {
        guard !isRunning else { return }
        isRunning = true
        scheduleTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        didFinishAndSave = false
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
            finishReading()
            return
        }
        remainingSeconds -= 1
    }

    func finishReading() {
        timer?.invalidate()
        timer = nil
        isRunning = false

        // prevent double-save if finishReading() is somehow called twice
        guard didFinishAndSave == false else { return }
        didFinishAndSave = true

        // calculate minutes actually spent
        // we track a countdown, so "elapsed" = planned - remaining
        let elapsedSeconds = max(0, (durationMinutes * 60) - remainingSeconds)
        let elapsedMinutesRoundedUp = Int(ceil(Double(elapsedSeconds) / 60.0))
        let minutesToPersist = max(1, elapsedMinutesRoundedUp)

        // only persist if we have a book
        guard let book = selectedBook else {
            #if DEBUG
            DebugLogger.log("⏱ FocusMode: no book selected, skipping save")
            #endif
            resetTimerStateAfterFinish()
            return
        }

        do {
            try sessionRepository.saveSession(
                book: book,
                minutes: minutesToPersist,
                date: Date(),
                medium: "reading"
            )

            #if DEBUG
            DebugLogger.log("✅ FocusMode saved session: \(minutesToPersist)min for \(book.title)")
            #endif
        } catch {
            #if DEBUG
            DebugLogger.log("❌ FocusMode save error: \(error)")
            #endif
        }

        resetTimerStateAfterFinish()
    }

    private func resetTimerStateAfterFinish() {
        // reset timer UI for next run
        remainingSeconds = durationMinutes * 60
    }

    func formattedRemaining() -> String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
