// Kontext: Dieser Service hält unsere Text-to-Speech-Pipeline zusammen.
// Warum: Hörmodus und Accessibility verlassen sich auf konsistente AVSpeechSynthesizer-Steuerung.
// Wie: Wir bündeln AVFoundation-Konfiguration, Queueing und Lifecycle in einem ObservableObject.
import Foundation
import AVFoundation

@MainActor
final class SpeechService: ObservableObject {

    // Singleton-Instanz für die App.
    static let shared = SpeechService()

    /// AVSpeechSynthesizer ist ein stateful Objekt von AVFoundation.
    /// Er bleibt hier im Service zentriert, damit nicht mehrere Synthesizer gleichzeitig laufen.
    /// Wichtig: NICHT private, damit AudiobookLightViewModel darauf zugreifen kann.
    let synthesizer = AVSpeechSynthesizer()

    private init() { }

    /// Startet Vorlesen eines gegebenen Textes.
    /// - Parameter text: Ganzer zu sprechender String.
    /// - Parameter language: BCP-47 Sprachcode wie "de-DE" oder "en-US".
    func speak(_ text: String, language: String = "de-DE", rate: Float? = nil, pitch: Float? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)

        if let rate {
            utterance.rate = rate
        }

        if let pitch {
            utterance.pitchMultiplier = pitch
        }

        synthesizer.speak(utterance)
    }

    /// Stoppt sofort die aktuelle Ausgabe.
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
