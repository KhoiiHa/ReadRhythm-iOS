# ReadRhythm – Case-Study Export Guide (Phase 6)

## Setup
- **Device:** iPhone 15 Pro (oder 6.7″ Pro Max, aber überall gleich)
- **Canvas:** Xcode Previews
- **Locale:** `.environment(\.locale, .init(identifier: "de"))`
- **Theme:** Light / Dark
- **Scale:** 1x (Retina)
- **Export:** Screenshot direkt aus der Canvas-Preview (rechts oben Kamera-Symbol)

## Export-Liste
| Nr | Preview-Titel | Dateiname |
|----|----------------|------------|
| 01 | Insights – Light (DE) | `01_insights_light_de.png` |
| 02 | Insights – Dark (DE) | `02_insights_dark_de.png` |
| 03 | Goals – 95% (Light DE) | `03_goals_95_light_de.png` |
| 04 | Goals – 105% (Dark DE) | `04_goals_105_dark_de.png` |
| 05 | DiscoverAll – Empty (Light DE) | `05_discover_empty_light_de.png` |
| 06 | DiscoverAll – Empty (Dark DE) | `06_discover_empty_dark_de.png` |
| 07 | DiscoverAll – Books (Light DE) | `07_discover_books_light_de.png` |
| 08 | DiscoverAll – Books (Dark DE) | `08_discover_books_dark_de.png` |
| 09 | Reviews – 3 Cards (Light DE) | `09_reviews_light_de.png` |
| 10 | Reviews – Empty (Dark DE) | `10_reviews_empty_dark_de.png` |

## Mini-Polish vor Export
- Keine Debug-Overlays, kein roter Rahmen.
- NavigationBar sichtbar, Statusbar ruhig.
- A11y-IDs gepflegt (`insights_chart`, `Goals.ProgressRing`, etc.).
- Strings alle deutsch (`goals.target.minutes`, `discover.cat.fiction`, …).

## Canva/Figma-Import
- **Format:** 1920 × 1080 px (Landscape) oder A4 Portrait.
- Screens paarweise platzieren (Light/Dark oder 95/105).
- Untertitel (klein, grau):
  - *„Deterministische Preview mit Dummy-Daten · DE-Locale“*
  - *„Ziele 95 % / 105 % – Progress & Badge-Test“*
  - *„Discover: Leerzustand & 3 Karten – Filter/Sort“*
