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

**ReadRhythm** ist eine iOS-App zum **Lesetracking und Hörzeit-Tracking**,  
fokussiert auf eine ruhige, klare User Experience und modernes SwiftUI-Design.  
Die App kombiniert Lesestatistiken, Hörbuchzeit und Achtsamkeit im digitalen Alltag.  

📱 **Technologien:** SwiftUI · SwiftData · Swift Charts · MVVM  
🎨 **Design-System:** AppColors · AppFont · AppSpace · AppRadius · AppShadow  
🧩 **Architektur:** MVVM + Repository + Service Pattern  

---

## 🧭 Zielsetzung

Ziel war es, eine App zu schaffen, die:
- **Fokus & Ruhe** fördert statt visuellem Overload  
- **Zustände klar trennt:** Lesen vs. Hören  
- **Architektonisch erweiterbar** bleibt für Portfolio- & Produktions-Use-Cases  
- **Visuell konsistent** im Light/Dark Mode ist  
- Und als **Portfolio-Projekt** technische Reife mit UX-Bewusstsein zeigt  

---

## 🏗 Architektur

**App-Layer:** `ReadRhythmApp`, `MainTabView`  
**Core:** Theme-System & Design Tokens (`AppColors`, `AppFont`, `AppSpace`, `AppRadius`, `AppShadow`)  
**Features:** Library · Discover · Stats · Profile · Settings  
**Repositories:** `BookRepository`, `SessionRepository`  
**Services:** `DataService`, `StatsService`, `AppSettingsService`, `SpeechService`, `AppFormatter`  

---

## ✨ Features

### 📚 Library
- Bücher hinzufügen, löschen, verwalten  
- BookDetail mit Sessions (Datum & Minuten)  
- Add-Session mit Haptic Feedback  
- SwiftData-basierte Persistenz  

### 🎧 Audiobook Light
- Text-to-Speech via `AVSpeechSynthesizer`  
- Echtzeit-Playback-Tracking  
- Speichert Hördauer automatisch als Session  

### 📊 Stats
- Lesestatistik per Swift Charts  
- Ziel-Linie (RuleMark) für tägliche Lese-Minuten  
- Integer-Y-Achse, klare BarMarks  
- i18n-kompatible Texte & VoiceOver-Labelling  

### 🧘‍♀️ Focus Mode
- Timer für Leseeinheiten  
- Sanfte Haptics & Fade-Animationen  
- Speichert Sitzungen automatisch als Lesesessions  

### ⚙️ Settings
- Theme-Picker (System, Light, Dark)  
- Persistente Speicherung über `AppSettingsService`  
- Debug-Reset für Demo-Daten  

---

## 🪄 Design-System

| Kategorie | Datei | Beschreibung |
|:--|:--|:--|
| Farben | `AppColors.swift` | Türkis-Sand-Farbwelt mit semantischen Tokens |
| Typografie | `AppFont.swift` | Strukturierte Hierarchie für Titel, Body, Caption |
| Abstände | `AppSpace.swift` | Einheitliche Layout-Spacing-Variablen |
| Radius | `AppRadius.swift` | Corner-Radius-Token |
| Schatten | `AppShadow.swift` | Weiche UI-Tiefenstufen für Cards & Panels |

> Designziel: „Ruhig, fokussiert, lesbar“ – inspiriert von modernen Reading Apps auf Behance.

---

## 🧩 Architektur-Philosophie

- **MVVM:** klare Layer-Trennung von Logik & UI  
- **Repository-Pattern:** abstrahiert Datenzugriff  
- **Service-Pattern:** aggregiert Berechnungen und Zustände  
- **SwiftData:** typensicheres Model-Layer mit Entity-Beziehungen  
- **Design Tokens:** garantieren UI-Konsistenz  

---

## 🧪 Teststrategie & Qualitätssicherung

**Kontext:** Fokus auf stabile, nachvollziehbare Logik-Tests statt UI-Flakiness.  
**Warum:** CI-taugliche Stabilität durch deterministische Tests der Kernmodule.  
**Wie:** Unit-Tests für Repositories, Services, Formatter – klar abgegrenzt vom UI-Schema.  

### Getestete Kernmodule
- **LocalSessionRepository:** validiert Idempotenz (keine Duplikate, kein Leak)  
- **StatsService:** aggregiert Lese- & Hörzeit korrekt über Datumsfenster  
- **SpeechService:** testet Lifecycle und Start/Stop-Übergänge synchron  
- **AppFormatter:** prüft lokalisierten Text + VoiceOver-Kompatibilität  

UI-Smoke-Tests (FocusMode, AudiobookLight, Stats, Profile) sind dokumentiert,  
aber **nicht Teil des CI-Schemes**, um Stabilität der Kernlogik zu priorisieren.  

> Alles, was produktionsrelevant ist, läuft deterministisch grün –  
> alles Visuelle bleibt als nachvollziehbarer Showcase im Repo.  

---

## 📦 Phase 12 – Code Freeze / Technischer Abschluss

🧩 **Status:** Alle Kern-Tests grün · Architektur stabil · Design-Tokens konsolidiert  
🧱 **UI-Smokes:** bleiben im Repo, aber außerhalb des CI-Laufs  
🎨 **Phase 11:** Branding Polish & Case Study Visuals vorbereitet  

**Commit-Vermerk:**  
> 🧪 QA: UI-Smokes optional, Kern-Tests grün  
> – Repositories & Services voll getestet  
> – SpeechService & Formatter deterministisch stabil  
> – Phase 12 = Code Freeze → Nächster Schritt: Case Study / Canva Export

---

## 📊 Screenshots & Visuals *(folgen in Canva-Phase)*

| Light Mode | Dark Mode |
|:--|:--|
| ![Focus Light](screenshots/focus_light.png) | ![Focus Dark](screenshots/focus_dark.png) |
| ![Stats Light](screenshots/stats_light.png) | ![Stats Dark](screenshots/stats_dark.png) |
| ![Profile Light](screenshots/profile_light.png) | ![Profile Dark](screenshots/profile_dark.png) |

---

## 🧠 Learnings

- Saubere MVVM-Architektur mit Repository & Service Layer  
- SwiftData + Swift Charts im produktionsnahen Setup  
- Micro-Interactions (Haptics, Fade) gezielt eingesetzt  
- Designsystem = visuelle Wartbarkeit  
- Logiktests > visuelle Tests: CI-ready Stabilität  
- Ruhe im UI = Klarheit im Denken  

---

## 📦 Setup

1. Repository klonen  
2. Öffne `ReadRhythm.xcodeproj` in **Xcode 16+**  
3. Zielgerät: **iOS 17+**  
4. Build & Run → Demo-Daten werden automatisch geladen  

---

## 💡 Autor

**Vu Minh Khoi Ha**  
📍 iOS Developer · Product Strategist · Portfolio-Projekt *ReadRhythm*  
📧 Kontakt auf Anfrage  

---

© 2025 Vu Minh Khoi Ha · Projekt: ReadRhythm
