<p align="center">
  <img src="https://res.cloudinary.com/dpaehynl2/image/upload/v1763909607/ReadRhythm_Banner_1600x900_v2qzle.png"
       alt="ReadRhythm Banner"
       width="640" />
</p>

<h1 align="center">📚 ReadRhythm – iOS Reading & Listening Tracker</h1>
<h3 align="center"><em>Track. Focus. Grow. – Built with SwiftUI · SwiftData · Swift Charts</em></h3>

<p align="center">
  <img src="https://img.shields.io/badge/SwiftUI-Framework-blue?logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/SwiftData-Ready-orange" />
  <img src="https://img.shields.io/badge/Architecture-MVVM-green" />
  <img src="https://img.shields.io/badge/Target-iOS_17+-lightgrey" />
  <img src="https://img.shields.io/badge/Tests-Core_Stable-success" />
  <img src="https://img.shields.io/badge/Phase-MVP_Hardening-blueviolet" />
</p>

---

## 🇩🇪 Einführung
ReadRhythm ist eine minimalistische, helle iOS-App, die **Lesen & Hören** in einer ruhigen SwiftUI-Oberfläche verbindet.
Von Bibliothek, Discover-Feed und Statistiken bis hin zum Fokusmodus – alles in einem klaren MVVM-Setup.

> Ziel: Fortschritt sichtbar machen, Ablenkung reduzieren und tägliches Lesen erleichtern.

## 🇬🇧 Introduction
ReadRhythm is a minimalist iOS app for **reading & listening**, wrapped in a calm SwiftUI interface.
It combines library management, discovery feeds, statistics and a focus mode — all built on a clean MVVM architecture.

> Goal: Make progress visible, reduce friction and help users build better reading habits.

---

## 📄 Case Study
📘 **ReadRhythm – Case Study (PDF)**
[ReadRhythm_CaseStudy.pdf](./ReadRhythm_CaseStudy.pdf)

Die Case Study beinhaltet Architektur, UX, technische Entscheidungen und persönliche Learnings.

---

## ✨ Hauptfeatures · Key Features

### 📚 Bibliothek / Library
- SwiftData-basierte Listen (`@Query`)
- Add-Sheet, Swipe-Actions, Toast-Feedback
- ViewModels kapseln CRUD-Logik

**EN:** SwiftData-backed lists with add sheet, swipe actions and clean MVVM separation.

---

### ✨ Discover & Empfehlungen / Discover & Recommendations
- Kombination aus Kategorie-Chips, Suchfeld und API-Ergebnissen  
- Repository orchestriert Google-Books-Requests mit Memory-Cache
- SwiftData persistiert gespeicherte Bücher für lokale Nutzung

**EN:**  
Discover mixes category chips, search, and remote results; a repository coordinates Google Books requests
with a memory cache and persists saved selections to SwiftData.

---

### 📊 Statistiken & Insights / Stats & Insights
- Swift Charts visualisieren tägliche Lesezeit, Streaks & Gesamtwerte  
- StatsService aggregiert Sitzungen über Zeiträume  
- Deterministische Tests für Statistiklogik

**EN:**  
Swift Charts visualize daily minutes, streaks, and totals; repository and StatsService aggregate sessions with deterministic test coverage.

---

### 🧘‍♀️ Ziele & Fokus / Goals & Focus Mode
- Progress Ring mit Haptics
- Fokus-Timer speichert Sessions automatisch
- Klarer, reduzierter „Deep Work“-Flow

---

### ⚙️ Settings & Theming
- Globaler Settings-Service steuert Theme & Sprache  
- SwiftData-Container + EnvironmentObjects  
- i18n-kompatible Texte und klare App-Konfiguration

---

## 🧩 Architekturüberblick · Architecture Overview

### 🇩🇪
ReadRhythm nutzt **MVVM** mit einem gemeinsamen SwiftData-Container (`PersistenceController.shared`).
Repositories kapseln zentrale Logik, ViewModels koordinieren Data-Flows und halten die Views sauber & testbar.

### 🇬🇧
Based on **MVVM** with a shared SwiftData container. Repositories abstract CRUD logic and view models marshal service flows cleanly.

---

### 🧠 Repository & Services
- Lokale Repositories (Book, Session) abstrahieren SwiftData-Zugriffe
- NetworkClient & GoogleBooksClient kapseln Remote-Requests
- DataService dient als zentraler CRUD- und Fallback-Layer

**EN:**
Local repositories abstract SwiftData access; network clients wrap Google Books APIs;
DataService serves as a central CRUD and persistence fallback layer.

---

### 🌐 Networking
- Gekapselte Netzwerkschicht mit Memory-Cache, URLSession & DTO-Mapping
- Memory-Cache für wiederholte Suchanfragen
- Testbare API-Schicht mit klarer Fehlerpropagierung

---

## 🎨 Design-System & UI

### 🇩🇪
Das UI nutzt ein helles, ruhiges Design basierend auf eigenen Tokens (`AppColors`).
Typografie, Abstände, Schatten und Radii sind konsistent gehalten.

> *Designziel:* „Ruhig, fokussiert, lesbar“.

### 🇬🇧
A clean and light UI built on custom color & typography tokens.
Consistent spacing, shadows and components across the app.

> *Design goal:* Calm, focused and readable.

---

## 🧠 Learnings & Challenges

**DE:**
- Aufbau einer repository-basierten Suche zeigte, wie Netzwerk, Mapping und lokale Speicherung zusammenspielen.
- Aggregationslogik im StatsService entlastet ViewModels und erhöht Testbarkeit.
- Design Tokens halten Light/Dark-Mode konsistent.
- Text-to-Speech & SwiftData-Tests zeigten Integration von AVFoundation + Persistence-Lifecycles.

**EN:**
- Implementing repository-based search connected networking, DTO mapping, and local persistence.
- StatsService aggregation logic proved how services offload logic from view models.
- Design tokens kept UI modes consistent and prevented duplication.
- TTS and SwiftData tests demonstrated reliable coordination between speech and data lifecycles.

---

## 🧪 Teststrategie

**Getestete Kernmodule:**
- LocalSessionRepository → validiert Session-Persistenz, Eingaben und Idempotenz
- StatsService → aggregiert Lesezeit deterministisch
- SpeechService → testet Start/Stop-Lifecycle
- AppFormatter → prüft lokalisierte Texte & VoiceOver-Kompatibilität
- ReadingGoalsViewModel → erstellt und aktualisiert aktive Ziele robust

> Fokus: deterministische Kernlogik, In-Memory-SwiftData-Tests und UI-Smokes für zentrale Flows.
> Hinweis: Testausführung erfolgt über Xcode/Xcodebuild; lokale Toolchain-Konfiguration kann vorausgesetzt sein.

---

## 🔧 Future Improvements

**DE:**
- DataService & LocalBookRepository zusammenführen, um doppelte Logik zu vermeiden.
- DiscoverViewModel-Dependencies explizit injizieren, um Tests zu vereinfachen.
- Fehlerhandling verbessern (kein `try!`, klare Propagierung).
- Debounce- oder Cancel-Logik für Suchfeld einführen.  
- Persistenten Discover-Feed-Cache als echten Offline-Fallback reaktivieren oder README/UI klar darauf verzichten lassen.

**EN:**
- Consolidate DataService & LocalBookRepository to eliminate duplication.
- Inject DiscoverViewModel dependencies explicitly to ease testing.
- Replace `try!` with safe error propagation.
- Add debouncing or cancellation to search task.
- Reactivate the persistent Discover feed cache as a real offline fallback or keep the product copy focused on saved books.

---

## 🧩 Tech Stack

- SwiftUI
- SwiftData
- Swift Charts
- Google Books API
- MVVM + Repository Pattern
- Unit Tests (deterministische Kernlogik)

---

## 💼 Recruiter Highlights

- Saubere MVVM-Architektur mit klaren Repository- & Service-Layern
- Unit-Tests für Stats, Speech, Goals und Session-Persistenz mit deterministischem Verhalten
- Design Tokens, i18n & Accessibility konsistent umgesetzt  
- MVP-Hardening mit klaren, kleinen und testbaren Verbesserungen dokumentiert
- Ready für Store- & Portfolio-Präsentation

---

## 🔐 Setup

1. Repository klonen
2. Öffne `ReadRhythm.xcodeproj` in **Xcode 16+**
3. Zielgerät: **iOS 17+**
4. Build & Run

---

## 🤝 Kontakt / Contact

**Minh Khoi Ha**
📍 Mobile App Developer (iOS · SwiftUI)
🔗 LinkedIn: https://www.linkedin.com/in/minh-khoi-ha
🔗 GitHub: https://github.com/KhoiiHa

---

<h3 align="center">📚 ReadRhythm – Read. Listen. Focus.</h3>
<p align="center"><em>Built with SwiftUI · SwiftData · Swift Charts.</em></p>
