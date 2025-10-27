// Kontext: Dieses ViewModel treibt den Fokusmodus an und hält die Session-State-Maschine in Schach.
// Warum: Ohne diesen Koordinator würden Timer, Buchbindung und Persistenz auseinanderlaufen.
// Wie: Wir orchestrieren Timer, Status und Saves über das SessionRepository und veröffentlichte Properties.
import Foundation
import SwiftData
import CoreHaptics
import SwiftUI


@MainActor
final class FocusModeViewModel: ObservableObject {
    // MARK: - Session lifecycle flags
    /// Wurde diese Session bereits persistiert? Dient als Schutz gegen Doppel-Saves.
    private var hasSavedSession: Bool = false

    // MARK: - Published UI State
    @Published var durationMinutes: Int = 25          // user-selected focus length in minutes
    @Published var remainingSeconds: Int = 25 * 60     // countdown timer state
    @Published var isRunning: Bool = false             // whether the timer is actively ticking
    @Published var selectedBook: BookEntity? = nil     // the book this focus session belongs to

    private var timer: Timer?

    // Repository responsible for persisting reading sessions
    private let sessionRepository: SessionRepository

    init(sessionRepository: SessionRepository) {
        self.sessionRepository = sessionRepository
        self.remainingSeconds = durationMinutes * 60
    }

    /// Startet eine neue Fokus-Session. Setzt Timer zurück und beginnt das Countdown-Tracking.
    func startSession() {
        guard isRunning == false else { return }
        hasSavedSession = false
        remainingSeconds = durationMinutes * 60
        isRunning = true
        scheduleTimer()
    }

    /// Pausiert die aktuelle Session, ohne sie zu speichern.
    func pauseSession() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    /// Führt eine pausierte Session fort.
    func resumeSession() {
        guard isRunning == false else { return }
        isRunning = true
        scheduleTimer()
    }

    /// Bricht die Session ab, verwirft den Fortschritt (KEIN Save) und setzt UI zurück.
    func cancelSessionWithoutSave() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        hasSavedSession = false
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
            stopSessionAndSave()
            return
        }
        remainingSeconds -= 1
    }

    /// Stoppt den Timer, berechnet die gelesene Zeit und persistiert sie (einmalig).
    /// Diese Funktion wird aufgerufen, wenn der User aktiv "Fertig" drückt
    /// ODER wenn der Timer natürlich auf 0 läuft.
    func stopSessionAndSave() {
        timer?.invalidate()
        timer = nil
        isRunning = false

        // Doppel-Save verhindern
        guard hasSavedSession == false else { return }
        hasSavedSession = true

        // berechne tatsächlich gelesene Minuten
        let elapsedSeconds = max(0, (durationMinutes * 60) - remainingSeconds)
        let elapsedMinutesRoundedUp = Int(ceil(Double(elapsedSeconds) / 60.0))
        let minutesToPersist = max(1, elapsedMinutesRoundedUp)

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

    deinit {
        // Timer hart stoppen, kein weiterer Tick nach View-Dismiss
        timer?.invalidate()
        timer = nil

        // Wir speichern NICHT automatisch beim deinit. Das verhindert Ghost-Sessions,
        // z. B. wenn der Nutzer den Screen einfach schließt.
        #if DEBUG
        DebugLogger.log("🧹 FocusModeViewModel deinit – timer invalidated, no auto-save")
        #endif
    }
}
