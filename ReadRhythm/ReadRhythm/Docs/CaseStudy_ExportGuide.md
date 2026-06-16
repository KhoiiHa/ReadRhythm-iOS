# ReadRhythm – Case-Study Export Guide

## Ziel
Dieser Guide definiert die Screenshots, die ReadRhythm als Portfolio-Projekt am klarsten zeigen.
Der Fokus liegt auf den gehärteten Kernflows: Library, Book Detail, Session-Tracking, History,
Stats, Goals und Discover. Neue Screenshots sollten erst exportiert werden, wenn der jeweilige
Flow lokal geprüft und der `main`-Branch grün ist.

## Setup
- **Branch:** `main`
- **Device:** iPhone 15 Pro oder iPhone 15 Pro Max, aber innerhalb eines Exports konsistent
- **Canvas:** Xcode Previews oder Simulator-Screenshot
- **Locale:** Deutsch zuerst, optional Englisch als Vergleich
- **Theme:** Light als Primärset, Dark nur für gezielte Kontrastvergleiche
- **Scale:** 1x für Canvas-Export, native Simulator-Auflösung für App-Screens
- **Export:** Screenshot direkt aus der Canvas-Preview oder aus dem iOS Simulator

## Export-Liste
| Priorität | Screen | Zustand | Dateiname |
|-----------|--------|---------|------------|
| 1 | Library | gespeicherte Bücher sichtbar | `01_library_books_light_de.png` |
| 2 | Book Detail | Session-CTA, Metadaten und Fortschritt sichtbar | `02_book_detail_session_light_de.png` |
| 3 | History | gruppierte Reading- und Listening-Sessions | `03_history_sessions_light_de.png` |
| 4 | Stats | Chart mit Daten, Range-Switch sichtbar | `04_stats_chart_light_de.png` |
| 5 | Goals | aktives Ziel mit Fortschritt | `05_goals_progress_light_de.png` |
| 6 | Focus Mode | laufender oder vorbereiteter Fokus-Timer | `06_focus_mode_light_de.png` |
| 7 | Discover | Suche/Kategorien mit Ergebnissen | `07_discover_books_light_de.png` |
| 8 | Empty State | ein repräsentativer leerer Zustand | `08_empty_state_light_de.png` |
| Optional | Stats | Empty State nach frischer Installation | `09_stats_empty_light_de.png` |
| Optional | Goals | Dark-Mode-Kontrastcheck | `10_goals_progress_dark_de.png` |

## Pflicht-Check vor Export
- App lokal auf einem frischen Simulator starten.
- Mindestens ein Buch speichern.
- Eine Reading-Session und eine Listening-Session anlegen.
- History per Pull-to-refresh prüfen.
- Stats per Pull-to-refresh prüfen.
- Goal setzen und Fortschritt sichtbar machen.
- GitHub Actions auf `main` muss grün sein.

## Mini-Polish
- Keine Debug-Overlays, kein roter Rahmen.
- Keine Demo-/Debug-Controls in sichtbaren App-Flows.
- NavigationBar sichtbar, Statusbar ruhig, keine abgeschnittenen Texte.
- Accessibility-Labels und VoiceOver-Zusammenfassungen auf den Kernflächen prüfen.
- Strings im Primärset deutsch, keine gemischten Fallback-Texte.
- Pull-to-refresh nicht im Screenshot festhalten, sondern nur das Ergebnis zeigen.

## Portfolio-Auswahl
Für README, GitHub-Profil oder Bewerbungsunterlagen reichen 4 bis 6 Screens:

1. Library
2. Book Detail mit Session-Tracking
3. History
4. Stats
5. Goals oder Focus Mode
6. Discover, falls der API-/Repository-Teil hervorgehoben werden soll

Alles darüber hinaus ist eher Case-Study-Material als README-Material.

## Canva/Figma-Import
- **Format:** 1920 x 1080 px Landscape oder A4 Portrait.
- Screens nach Flow gruppieren, nicht nach Implementierungsreihenfolge.
- Untertitel kurz halten und produktbezogen formulieren:
  - *"Session-Tracking direkt aus dem Book Detail"*
  - *"History gruppiert Reading- und Listening-Aktivität"*
  - *"Stats visualisieren Fortschritt mit Swift Charts"*
  - *"Goals und Focus Mode stützen tägliche Lesegewohnheiten"*

## Hinweise zur bestehenden PDF
Die vorhandene `ReadRhythm_CaseStudy.pdf` bleibt ein gültiger Portfolio-Snapshot.
Wenn neue Screens exportiert werden, sollte die PDF gezielt aktualisiert werden, statt sie
mit jedem kleinen Hardening-Commit neu zu erzeugen.

## Aktualisierungsentscheidung
Die PDF muss nicht nach jedem technischen Hardening neu gebaut werden. Eine Aktualisierung lohnt sich
erst, wenn mindestens einer dieser Punkte zutrifft:

- Der visuelle Hauptflow hat sich sichtbar verändert.
- Neue Screenshots sollen aktiv in Bewerbungen, LinkedIn oder Portfolio-Seiten verwendet werden.
- README und PDF widersprechen sich in Kernfeatures, Projektstatus oder Architektur.
- App-Store- oder TestFlight-Material wird vorbereitet.

Für kleine README-, Test-, CI- oder Logging-Verbesserungen reicht ein kurzer Hinweis im README.
Der aktuelle technische Stand bleibt dort und im PR-Verlauf nachvollziehbar.
