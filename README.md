# 📚 ReadRhythm – iOS Reading Tracker App (Portfolio Case Study)

![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-blue?logo=swift&logoColor=white)
![SwiftData](https://img.shields.io/badge/SwiftData-Ready-orange)
![MVVM](https://img.shields.io/badge/Architecture-MVVM-green)
![iOS17](https://img.shields.io/badge/Target-iOS_17+-lightgrey)

> *“Track your reading habits, visualize your progress, and rediscover the joy of mindful reading.”*  
> Developed as part of my iOS Portfolio Project · SwiftUI · MVVM · SwiftData · Swift Charts

---

## 🌟 Overview

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
**Services:** `DataService`, `StatsService`, `AppSettingsService`

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
- Horizontal scrollbare Buchcover (Cards)  
- Dynamische Sections & Seed-Daten  
- Reusable Components (`BookCoverCard`, `SectionHeader`)  

### ⚙️ Settings
- Theme-Picker (System, Light, Dark)  
- Persistente Speicherung über `AppSettingsService`  
- Debug-Reset für Demo-Daten  
- Live Theme Preview  

---

## 🧠 Phase 4 – Neue Features

> *Diese Sektion ergänzt Phase 4 – Extra Screens & UX Extensions.*

### 🎯 Reading Goals
Visualisiere tägliche/wöchentliche Lesefortschritte mit einem **Progress Ring**  
und personalisierten Zielen (z. B. 30 Minuten pro Tag).

### 🎧 Audiobook Light
Text-to-Speech-Integration mit Playback-Tracking.  
Demonstriert Swift Concurrency & AVFoundation-Einsatz.

### 🧑‍💻 Profile & Insights
Statistische Übersicht über Lesegewohnheiten, Genres, Gesamtminuten.  
Optionale Integration mit Swift Charts & Core ML für Lesetrends.

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
- **Service-Pattern:** zuständig für Aggregation, Berechnung, API-Bridges  
- **SwiftData-Integration:** Entity-basiertes, typensicheres Datenmodell  
- **Design Tokens:** visuelle Konsistenz & schnelle Theme-Anpassung  

---

## 📊 Screenshots & Visuals *(nach Phase 4 ergänzen)*

| Light Mode | Dark Mode |
|:--|:--|
| ![Library Light](screenshots/library_light.png) | ![Library Dark](screenshots/library_dark.png) |
| ![Stats Light](screenshots/stats_light.png) | ![Stats Dark](screenshots/stats_dark.png) |
| ![Settings Light](screenshots/settings_light.png) | ![Settings Dark](screenshots/settings_dark.png) |

> *(Platzhalter – Screenshots aus Xcode oder Simulator einfügen)*

---

## 🧪 Debug & Developer Tools

- Seed-Daten nur unter `#if DEBUG`  
- Reset Demo Data in Settings verfügbar  
- Logging mit `print("[DEBUG] …")`  
- SwiftUI Previews für alle Haupt-Views (Light/Dark)

---

## 🧩 Lokalisierung & Accessibility

- Vollständig lokalisiert (`Localizable.strings`)  
- `AccessibilityIdentifiers` für UI-Tests  
- Dynamic Type kompatibel  
- SF Symbols: hierarchisch & semantisch passend  

---

## 🧠 Learnings

- MVVM-Architektur mit SwiftData verknüpft  
- Theme-Persistenz via ObservableObject + UserDefaults  
- Swift Charts + RuleMarks für verständliche Visualisierungen  
- Haptics + Micro-Interactions = hochwertiges Nutzergefühl  
- Portfolio-Clean-Code-Struktur: erweiterbar, lesbar, testbar  

---

## 📦 Setup

1. Repository klonen  
2. Öffne `ReadRhythm.xcodeproj` in **Xcode 16+**  
3. Zielgerät: **iOS 17+** (Device oder Simulator)  
4. Build & Run → Demo-Daten werden automatisch geladen  

---

## 💡 Autor

**Vu Minh Khoi Ha**  
📍 iOS Developer · Product Strategist · Portfolio Projekt ReadRhythm  
📧 Kontakt auf Anfrage

---

© 2025 Vu Minh Khoi Ha · Projekt: ReadRhythm
