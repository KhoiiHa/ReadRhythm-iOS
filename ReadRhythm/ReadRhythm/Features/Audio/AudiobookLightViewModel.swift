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
    // Public State
    @Published var text: String
    @Published var isSpeaking: Bool = false
    @Published var isPaused: Bool = false
    @Published var progress: Double = 0.0 // 0...1
    @Published var elapsedCharacters: Int = 0
    @Published var totalCharacters: Int = 0
    @Published var rate: Float = AVSpeechUtteranceDefaultSpeechRate // 0.0...1.0 (plattformabhängig)
    @Published var pitch: Float = 1.0 // 0.5...2.0
    @Published var languageCode: String

    // Dauer-Tracking für Hörsessions
    @Published var elapsedSeconds: Int = 0

    // Private
    private let synthesizer = AVSpeechSynthesizer()
    private var utterance: AVSpeechUtterance?
    private var currentText: NSString = ""

    // Timer, um die Hördauer zu zählen (1s-Ticks, ähnlich FocusMode)
    private var timer: Timer?

    // Repository zum Persistieren der Session (analog FocusModeViewModel)
    private let sessionRepository: SessionRepository

    // verhindert doppeltes Speichern beim Stop
    private var didFinalizeSession = false

    init(
        initialText: String = "",
        languageCode: String? = nil,
        sessionRepository: SessionRepository
    ) {
        self.text = initialText
        self.languageCode = languageCode
            ?? Locale.preferredLanguages.first
            ?? Locale.current.identifier
        self.sessionRepository = sessionRepository
        super.init()
        synthesizer.delegate = self
        self.totalCharacters = initialText.count
    }

    // MARK: Controls
    func play() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Wenn pausiert -> resume
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
        didFinalizeSession = false
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

    func pause() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .immediate)
        isPaused = true
        isSpeaking = false
        stopTimer()
    }

    func stop() {
        guard synthesizer.isSpeaking || isPaused else { return }

        synthesizer.stopSpeaking(at: .immediate)
        isPaused = false
        isSpeaking = false

        stopTimer()
        finishListening()
    }

    private func startTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func finishListening() {
        // Doppelspeicher verhindern
        guard didFinalizeSession == false else { return }
        didFinalizeSession = true

        // Minuten aus Sekunden runden (mind. 1 Minute)
        let minutes = max(
            1,
            Int(ceil(Double(elapsedSeconds) / 60.0))
        )

        // Persistieren
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

        // UI-State nach Abschluss zurücksetzen
        progress = 0
        elapsedCharacters = 0
        totalCharacters = text.count
        elapsedSeconds = 0
    }

    // MARK: Helpers
    func updateRate(_ newValue: Double) {
        // Begrenze in einem angenehmen Bereich
        rate = Float(min(max(newValue, 0.35), 0.65))
        // Live-Übernahme nur beim nächsten Utterance-Start
    }

    func updatePitch(_ newValue: Double) {
        pitch = Float(min(max(newValue, 0.75), 1.5))
    }

    private func bestVoiceCode() -> String {
        // Wenn languageCode z.B. "de-DE" enthält: nutze das, sonst fallback
        if AVSpeechSynthesisVoice(language: languageCode) != nil { return languageCode }
        if let de = AVSpeechSynthesisVoice(language: "de-DE") { return de.language }
        return AVSpeechSynthesisVoice.speechVoices().first?.language ?? "en-US"
    }

    deinit {
        timer?.invalidate()
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension AudiobookLightViewModel: AVSpeechSynthesizerDelegate {
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
            self.stopTimer()
            self.finishListening()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false
            self.stopTimer()
            self.finishListening()
        }
    }
}
