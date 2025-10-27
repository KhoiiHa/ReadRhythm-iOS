//
//  AudiobookLightViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
final class AudiobookLightViewModel: NSObject, ObservableObject {

    // MARK: - Session lifecycle flags
    /// Wurde diese Hör-Session bereits persistiert? Schutz gegen Doppel-Save.
    private var hasSavedSession: Bool = false

    // MARK: - Public State (UI-bindbar)
    @Published var text: String
    @Published var isSpeaking: Bool = false
    @Published var isPaused: Bool = false
    @Published var progress: Double = 0.0 // 0...1
    @Published var elapsedCharacters: Int = 0
    @Published var totalCharacters: Int = 0
    @Published var rate: Float = AVSpeechUtteranceDefaultSpeechRate // 0.0...1.0 abhängig von System
    @Published var pitch: Float = 1.0 // 0.5...2.0
    @Published var languageCode: String

    /// Laufzeit-Tracking für Hörsessions in Sekunden
    @Published var elapsedSeconds: Int = 0

    // MARK: - Private/Internal Dependencies
    private let speechService: SpeechService

    /// Der AVSpeechSynthesizer selbst gehört dem SpeechService.
    /// Wichtig: NICHT private, damit die Delegate-Extension im selben Modul legal darauf zugreifen darf.
    let synthesizer: AVSpeechSynthesizer

    private var utterance: AVSpeechUtterance?
    private var currentText: NSString = ""

    /// Timer, um jede Sekunde Hörzeit draufzurechnen.
    private var timer: Timer?

    /// Repository zum Persistieren der Session (analog FocusModeViewModel)
    private let sessionRepository: SessionRepository

    // MARK: - Init
    init(
        initialText: String = "",
        languageCode: String? = nil,
        sessionRepository: SessionRepository,
        speechService: SpeechService
    ) {
        self.text = initialText
        self.languageCode = languageCode
            ?? Locale.preferredLanguages.first
            ?? Locale.current.identifier

        self.sessionRepository = sessionRepository
        self.speechService = speechService
        self.synthesizer = speechService.synthesizer

        super.init()

        // Wir sind Delegate für AVSpeechSynthesizer
        self.synthesizer.delegate = self

        // Initialer Textstatus
        self.totalCharacters = initialText.count
    }

    // MARK: - Public Controls

    /// Startet oder setzt eine Hör-Session fort.
    /// - Wenn pausiert: setzt an der aktuellen Stelle fort.
    /// - Wenn neu: beginnt frische Session und setzt Tracking zurück.
    func startListeningSession() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Resume-Fall: wir waren pausiert
        if isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
            isSpeaking = true
            startTimerIfNeeded()
            return
        }

        // Neustart einer Session
        progress = 0
        elapsedCharacters = 0
        totalCharacters = trimmed.count
        currentText = trimmed as NSString

        // Session-Tracking zurücksetzen
        hasSavedSession = false
        elapsedSeconds = 0

        let u = AVSpeechUtterance(string: trimmed)
        u.voice = AVSpeechSynthesisVoice(language: bestVoiceCode())
        u.rate = rate
        u.pitchMultiplier = min(max(pitch, 0.5), 2.0)

        utterance = u
        synthesizer.speak(u)

        isSpeaking = true
        isPaused = false

        startTimerIfNeeded()
    }

    /// Pausiert die aktuelle Hör-Session (kein Persistieren).
    func pauseListeningSession() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .immediate)
        isPaused = true
        isSpeaking = false
        stopTimer()
    }

    /// Bricht die Session ab und verwirft Fortschritt ohne zu speichern.
    /// Nutzt man z. B. wenn der User bewusst abbricht.
    func cancelSessionWithoutSave() {
        guard synthesizer.isSpeaking || isPaused else { return }

        synthesizer.stopSpeaking(at: .immediate)
        isPaused = false
        isSpeaking = false

        stopTimer()
        resetAfterFinish(didPersist: false)
    }

    /// Beendet die Session und persistiert die gehörte Dauer genau einmal.
    /// Wird aufgerufen, wenn der User bewusst stoppt ODER wenn die Sprachausgabe natürlich endet.
    func stopSessionAndSave() {
        // Doppel-Save verhindern
        guard hasSavedSession == false else { return }
        hasSavedSession = true

        // Sekunden -> Minuten, aufrunden, min. 1 Minute
        let minutes = max(
            1,
            Int(ceil(Double(elapsedSeconds) / 60.0))
        )

        do {
            try sessionRepository.saveSession(
                book: nil,                // kein konkretes Buch verknüpft
                minutes: minutes,
                date: Date(),
                medium: "listening"
            )

            #if DEBUG
            DebugLogger.log("🎧 Saved listening session: \(minutes)min")
            #endif
        } catch {
            #if DEBUG
            DebugLogger.log("❌ Failed to save listening session: \(error)")
            #endif
        }

        resetAfterFinish(didPersist: true)
    }

    // MARK: - Private helpers

    /// Setzt den ViewModel-Status nach Abschluss oder Abbruch zurück.
    /// - Parameter didPersist: true, wenn wir wirklich gespeichert haben.
    private func resetAfterFinish(didPersist: Bool) {
        progress = 0
        elapsedCharacters = 0
        totalCharacters = text.count
        elapsedSeconds = 0
        isSpeaking = false
        isPaused = false
    }

    /// Startet den 1s-Timer, der die gehörte Dauer mitzählt.
    private func startTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }

    /// Stoppt und verwirft den Timer.
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // UI-Tuning für Rate und Pitch

    func updateRate(_ newValue: Double) {
        // Begrenze in einem angenehmen Bereich. Effekt gilt beim nächsten Utterance.
        rate = Float(min(max(newValue, 0.35), 0.65))
    }

    func updatePitch(_ newValue: Double) {
        pitch = Float(min(max(newValue, 0.75), 1.5))
    }

    private func bestVoiceCode() -> String {
        // Falls languageCode z.B. "de-DE" ist und es dafür eine Stimme gibt: nutze die.
        if AVSpeechSynthesisVoice(language: languageCode) != nil {
            return languageCode
        }
        // Fallback auf Deutsch wenn möglich
        if let de = AVSpeechSynthesisVoice(language: "de-DE") {
            return de.language
        }
        // Letzter Fallback: irgendeine verfügbare Stimme
        return AVSpeechSynthesisVoice.speechVoices().first?.language ?? "en-US"
    }

    @MainActor
    deinit {
        // Wichtig: Wir auto-saven NICHT im deinit.
        stopTimer()
        synthesizer.stopSpeaking(at: .immediate)

        #if DEBUG
        DebugLogger.log("🧹 AudiobookLightViewModel deinit – timer invalidated, speech stopped, no auto-save")
        #endif
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension AudiobookLightViewModel: AVSpeechSynthesizerDelegate {

    // Wichtiges Muster hier:
    // Die Delegate-Methoden selbst sind "nonisolated", damit wir das AVFoundation-Protokoll
    // ohne Actor-Konflikte erfüllen können. Wir greifen NICHT direkt auf MainActor-State zu.
    // Stattdessen hoppen wir explizit in Task { @MainActor in ... } zurück, bevor wir
    // irgendwelche @Published-States anfassen oder stopTimer()/stopSessionAndSave() aufrufen.

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       willSpeakRangeOfSpeechString characterRange: NSRange,
                                       utterance: AVSpeechUtterance) {

        Task { @MainActor in
            self.elapsedCharacters = characterRange.location + characterRange.length
            let total = max(self.totalCharacters, 1)
            self.progress = min(1.0, Double(self.elapsedCharacters) / Double(total))
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didFinish utterance: AVSpeechUtterance) {

        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false
            self.progress = 1.0

            // Diese Calls sind MainActor-isoliert, deshalb rufen wir sie
            // nur innerhalb des Task { @MainActor in ... } Blocks auf.
            self.stopTimer()
            self.stopSessionAndSave()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didCancel utterance: AVSpeechUtterance) {

        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false

            self.stopTimer()
            self.cancelSessionWithoutSave()
        }
    }
}
