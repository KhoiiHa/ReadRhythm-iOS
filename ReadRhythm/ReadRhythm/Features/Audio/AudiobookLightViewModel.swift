//
//  AudiobookLightViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import Foundation
import AVFoundation

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

    // Private
    private let synthesizer = AVSpeechSynthesizer()
    private var utterance: AVSpeechUtterance?
    private var currentText: NSString = ""

    init(initialText: String = "", languageCode: String? = nil) {
        self.text = initialText
        self.languageCode = languageCode
            ?? Locale.preferredLanguages.first
            ?? Locale.current.identifier
        super.init()
        synthesizer.delegate = self
        self.totalCharacters = initialText.count
    }

    // MARK: Controls
    func play() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Wenn pausiert, resume:
        if isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
            isSpeaking = true
            return
        }

        // Neustart
        progress = 0
        elapsedCharacters = 0
        totalCharacters = trimmed.count
        currentText = trimmed as NSString

        let u = AVSpeechUtterance(string: trimmed)
        u.voice = AVSpeechSynthesisVoice(language: bestVoiceCode())
        u.rate = rate
        u.pitchMultiplier = min(max(pitch, 0.5), 2.0)

        utterance = u
        synthesizer.speak(u)
        isSpeaking = true
        isPaused = false
    }

    func pause() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .immediate)
        isPaused = true
        isSpeaking = false
    }

    func stop() {
        guard synthesizer.isSpeaking || isPaused else { return }
        synthesizer.stopSpeaking(at: .immediate)
        isPaused = false
        isSpeaking = false
        progress = 0
        elapsedCharacters = 0
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
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false
        }
    }
}
