// Kontext: Wir definieren ein einheitliches Typografie-System für ReadRhythm.
// Warum: Konsistente Schriftgrößen stärken das Branding und reduzieren Styling-Duplikate.
// Wie: Statische SwiftUI-Fonts stellen klar benannte Tokens bereit, die Views konsumieren.
import SwiftUI

/// Kontext → Warum → Wie
/// - Kontext: Typografie-Tokens für die Portfolio-Phase, abgestimmt auf ruhige Lesbarkeit.
/// - Warum: Gemeinsame Einstiegspunkte erleichtern spätere Anpassungen (Size, Weight, Dynamic Type).
/// - Wie: `Font.system` stellt adaptive Fonts bereit, die per Token in den Views verwendet werden.
enum AppFont {
    /// Großer Titel für Hero-Inhalte (z. B. Timer, Tagesziel)
    static var titleLarge: Font {
        .system(size: 32, weight: .semibold, design: .default)
    }

    /// Primäre Überschrift in Detail- und Übersichts-Views
    static var title: Font {
        .system(size: 22, weight: .semibold, design: .default)
    }

    /// Standard-Textkörper für längere Beschreibungen
    static var body: Font {
        .system(size: 17, weight: .regular, design: .default)
    }

    /// Begleittext, Labels und Meta-Informationen
    static var caption: Font {
        .system(size: 13, weight: .regular, design: .default)
    }
}
