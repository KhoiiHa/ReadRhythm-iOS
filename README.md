# 📚 ReadRhythm – iOS Reading Tracker App (Portfolio Case Study)

![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-blue?logo=swift&logoColor=white)
![SwiftData](https://img.shields.io/badge/SwiftData-Ready-orange)
![MVVM](https://img.shields.io/badge/Architecture-MVVM-green)
![iOS17](https://img.shields.io/badge/Target-iOS_17+-lightgrey)
![QA](https://img.shields.io/badge/Tests-Core_Stable-success)
![Status](https://img.shields.io/badge/Phase-Code_Freeze_✅-blueviolet)

> *„Track your reading habits, visualize your progress, and rediscover the joy of mindful reading.“*  
> Developed as part of my iOS Portfolio Project · SwiftUI · MVVM · SwiftData · Swift Charts

---

## 🌟 Überblick

**ReadRhythm** ist eine iOS-App zum **Lesetracking und Buchverwaltung**,  
fokussiert auf ruhige, klare User Experience und modernes SwiftUI-Design.  
Die App ermöglicht es, Bücher hinzuzufügen, Lesesessions zu erfassen,  
Statistiken zu visualisieren und Themes (Light/Dark/System) flexibel zu steuern.

📱 **Technologien:** SwiftUI · SwiftData · Swift Charts · MVVM  
🎨 **Design-System:** AppColors · AppSpace · AppRadius · AppShadow  
🧩 **Architektur:** MVVM + Repository + Service Pattern

---

## 🧭 Zielsetzung

Ziel des Projekts war es, eine App zu entwickeln, die:
- **Alltagstauglich & ruhig** gestaltet ist (Fokus auf Lesefluss)  
- **Modular & erweiterbar** bleibt (MVP → Portfolio → Production)  
- **Visuell stimmig** zwischen Light & Dark Mode funktioniert  
- Und als **Portfolio-Projekt** den gesamten iOS-Entwicklungsprozess zeigt

---

## 🏗 Architektur

**App-Layer:** `ReadRhythmApp`, `MainTabView`  
**Core:** Theme-System & Design Tokens (`AppColors`, `AppSpace`, `AppRadius`, `AppShadow`)  
**Features:** Library · Discover · Stats · Settings (MVVM)  
**Repositories:** `BookRepository`, `SessionRepository`  
**Services:** `DataService`, `StatsService`, `AppSettingsService`, `SpeechService`, `AppFormatter`

---

## ✨ Features

### 📚 Library
- Bücher hinzufügen, löschen, verwalten  
- BookDetail mit Sessions (Datum & Minuten)  
- Add-Session mit Haptic Feedback  
- SwiftData-basierte Persistenz  

### 📊 Stats
- Lesestatistik per Swift Charts  
- Ziel-Linie (RuleMark) für tägliche Leseminuten  
- Integer-Y-Achse, klare BarMarks  
- Empty-State mit SF-Symbolen & i18n  

### 🌸 Discover
- API-Integration mit lokalem Fallback (Karussells & Suche)  
- Dynamische Sections mit Seed-Daten  
- Reusable Components (`BookCoverCard`, `SectionHeader`)  

### 🎧 Audiobook Light
- Text-to-Speech via `AVSpeechSynthesizer`  
- Echtzeit-Playback-Tracking  
- Speichert Hördauer automatisch als Session  

### ⚙️ Settings
- Theme-Picker (System, Light, Dark)  
- Persistente Speicherung über `AppSettingsService`  
- Debug-Reset für Demo-Daten  
- Live Theme Preview  

---

## 🪄 Design-System

| Kategorie | Datei | Beschreibung |
|:--|:--|:--|
| Farben | `AppColors.swift` | Marken-, Akzent- & Neutralfarben (Light/Dark) |
| Abstände | `AppSpace.swift` | Einheitliche Layout-Spacing-Variablen |
| Radius | `AppRadius.swift` | Corner-Radius-Token |
| Schatten | `AppShadow.swift` | Weiche UI-Tiefenstufen |
| Typografie | System Font (SF Pro / Inter) | Lesbar, ruhig, modern |

---

## 🧩 Architektur-Philosophie

- **MVVM:** saubere Trennung von Logik und UI  
- **Repository-Pattern:** isolierte Datenquellen  
- **Service-Pattern:** aggregiert Berechnungen und Zustände  
- **SwiftData-Integration:** Entity-basiertes, typensicheres Datenmodell  
- **Design Tokens:** visuelle Konsistenz & Theme-Anpassung  

---

## 🧪 Teststrategie & Qualitätssicherung

Kontext: Ich betreibe ReadRhythm als Solo-Projekt mit Fokus auf einer belastbaren Codebasis, die Recruiter:innen sofort nachvollziehen können.  
Warum: Für Portfolio und Produktivität zählt vor allem, dass Persistenz, Auswertungen und Accessibility-konforme Formatter zuverlässig funktionieren.  
Wie: Die Kernlogik liegt in deterministischen Unit-Tests, die ohne flüchtige Simulator-Zustände laufen und damit stabil CI-fähig sind.

Die Unit-Suite deckt die wesentlichen Domänenbausteine ab:  
Das Session-Repository wird auf erfolgreiches Speichern, Idempotenz und Löschen geprüft, sodass keine Duplikate oder Leaks entstehen.  
Der StatsService wird mit gemischten Lese- und Hör-Szenarien gefüttert und berechnet daraus Tages- und Zeitfenster-Minuten, was die Portfolio-relevanten KPIs absichert.  
Der SpeechService-Test verifiziert den Singleton-Lebenszyklus sowie speak/stop-Übergänge ohne Timing-Flakiness,  
und AppFormatter garantiert lokalisierte Texte inklusive VoiceOver-Strukturen.

Zusätzlich existiert eine UI-Smoke-Schicht, die Tab-Bar, Fokus-Timer, Audiobook-Light-Flow, Stats-Chart und Profilnavigation ansteuert,  
um die End-to-End-Erfahrung nachzustellen.  
Diese UI-Szenarien bleiben bewusst außerhalb des Standard-Schemes, weil sie stark von Onboarding-Zuständen, Seed-Daten und Simulator-Tempo abhängen.  
Sie dienen als dokumentierte Portfolio-Smokes, nicht als Blocking-CI-Checks.

Ich entscheide mich damit klar für robuste Logik-Tests plus optionale UI-Skripte:  
Alles, was businesskritisch ist, läuft deterministisch grün; alles, was visuell demonstriert wird, bleibt als nachvollziehbare Ergänzung im Repo,  
ohne den stabilen Build zu gefährden.

---

## 📦 Phase 12 – Code Freeze / Technischer Abschluss

🧩 **Status:** Alle Kern-Tests laufen grün, Architektur stabilisiert, Design-Tokens & Services konsolidiert.  
🧱 **UI-Smoke-Tests:** Im Repository dokumentiert, aber aus dem Standard-Scheme entfernt (laufen nicht automatisch).  
🧠 **Nächster Schritt:** Phase 11 – Branding Polish & Case Study Visuals.

Commit-Vermerk (für Git History):  
> 🧪 QA-Dokumentation: UI-Smokes optional gehalten, Kern-Tests grün  
> – UI-Smoke-Tests verbleiben im Repo, laufen aber nicht mehr automatisch im Scheme  
> – Alle produktionsrelevanten Tests (Repository, Stats, Speech, Formatter) sind grün  
> – Phase 12 ist technisch eingefroren; als Nächstes folgt Phase 11 mit Branding-Polish und Case-Study-Screenshots

---

## 📊 Screenshots & Visuals *(noch ergänzen)*

| Light Mode | Dark Mode |
|:--|:--|
| ![Library Light](screenshots/library_light.png) | ![Library Dark](screenshots/library_dark.png) |
| ![Stats Light](screenshots/stats_light.png) | ![Stats Dark](screenshots/stats_dark.png) |
| ![Settings Light](screenshots/settings_light.png) | ![Settings Dark](screenshots/settings_dark.png) |

> *(Platzhalter – Screenshots aus Xcode oder Simulator kommen noch)*

---

## 🧠 Learnings

- MVVM-Architektur mit SwiftData verknüpft  
- Theme-Persistenz via ObservableObject + UserDefaults  
- Swift Charts + RuleMarks für verständliche Visualisierungen  
- Haptics + Micro-Interactions = hochwertiges Nutzergefühl  
- Portfolio-Clean-Code-Struktur: erweiterbar, lesbar, testbar  
- Strategische Testplanung mit Fokus auf Logik- statt UI-Flows  

---

## 📦 Setup

1. Repository klonen  
2. Öffne `ReadRhythm.xcodeproj` in **Xcode 16+**  
3. Zielgerät: **iOS 17+** (Device oder Simulator)  
4. Build & Run → Demo-Daten werden automatisch geladen  

---

## 💡 Autor

**Vu Minh Khoi Ha**  
📍 iOS Developer · Portfolio Projekt ReadRhythm  
📧 Kontakt auf Anfrage
---

© 2025 Vu Minh Khoi Ha · Projekt: ReadRhythm
