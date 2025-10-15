//
//  SpeechService.swift
//  ReadRhythm
//
//  Verwaltet Text-to-Speech (TTS) Funktionen für ReadRhythm.
//  Ziel: Bücher oder Textabschnitte vorlesen (Hörmodus / Accessibility).
//

import Foundation
import AVFoundation

final class SpeechService: ObservableObject {
    static let shared = SpeechService()
    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speak(_ text: String, language: String = "de-DE") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
