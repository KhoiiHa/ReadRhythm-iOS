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
  <img src="https://github.com/KhoiiHa/ReadRhythm-iOS/actions/workflows/ios-unit-tests.yml/badge.svg" />
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

## ✅ Aktueller Projektstatus · Current Status

**DE:**
ReadRhythm befindet sich nach mehreren gezielten Hardening-Blöcken auf einem stabilen Portfolio-Stand:
Session-Speicherung, History, Stats, Goals und Speech-Tests sind über Unit-Tests abgesichert.
GitHub Actions führt die Unit-Test-Suite automatisch für Pull Requests und `main`-Pushes aus.

**EN:**
ReadRhythm is currently in a hardened portfolio-ready state:
session persistence, history, stats, goals, and speech tests are covered by focused unit tests.
GitHub Actions runs the unit test suite automatically for pull requests and pushes to `main`.

---

## 🔎 Schnellreview für Recruiter · Quick Review

**Was dieses Projekt zeigen soll:**
- Eine echte SwiftUI-App mit mehreren verbundenen Produktflows statt isolierter Screens.
- MVVM mit Repositories/Services, SwiftData-Persistenz und testbarer Kernlogik.
- Kleine, nachvollziehbare Hardening-Schritte über Pull Requests, CI und gezielte Tests.

**Empfohlene Review-Reihenfolge:**
1. `README.md` für Produktumfang, Architektur und Teststrategie.
2. `ReadRhythm_CaseStudy.pdf` für UX-/Architektur-Kontext.
3. `ReadRhythm/ReadRhythm/Features` für SwiftUI- und ViewModel-Struktur.
4. `ReadRhythm/ReadRhythmTests` für Persistenz-, Stats-, Goals- und Service-Tests.
5. GitHub Actions / Pull Requests für Workflow, CI und inkrementelle Verbesserung.

**Scope-Hinweis:**
ReadRhythm ist bewusst ein Portfolio-/MVP-Hardening-Projekt, keine vollständig veröffentlichte App-Store-App.
Der Fokus liegt auf sauberer Architektur, Kernflows, Persistenz, Testing und nachvollziehbaren Produktentscheidungen.

---

## ✨ Hauptfeatures · Key Features

### 📚 Bibliothek / Library
- SwiftData-basierte Listen (`@Query`)
- Add-Sheet, Swipe-Actions, Toast-Feedback
- ViewModels kapseln CRUD-Logik
- Book Detail ermöglicht das Speichern neuer Sessions mit sichtbarem Feedback

**EN:** SwiftData-backed lists with add sheet, swipe actions, session logging from book details, and clean MVVM separation.

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
- Pull-to-refresh aktualisiert sichtbare Statistikdaten nach neuen Sessions

**EN:**  
Swift Charts visualize daily minutes, streaks, and totals; repository and StatsService aggregate sessions with deterministic test coverage and refreshable UI state.

---

### 🕘 Historie / History
- Chronologische Session-Liste mit Tagesgruppen
- Reading- und Listening-Sessions werden über passende Icons getrennt
- Pull-to-refresh lädt gespeicherte Aktivitäten erneut
- ViewModel formatiert Row-Texte und Accessibility-Labels zentral

**EN:**
Chronological session history grouped by day, with refresh support and centralized formatting for row text and accessibility labels.

---

### 🧘‍♀️ Ziele & Fokus / Goals & Focus Mode
- Progress Ring mit Haptics
- Fokus-Timer speichert Sessions automatisch
- Klarer, reduzierter „Deep Work“-Flow
- Aktivität bleibt sichtbar, auch wenn noch kein aktives Ziel gesetzt ist

**EN:** Focus mode stores sessions, goals show progress clearly, and current activity remains visible even without an active goal.

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
- LocalSessionRepository validiert Minuten und verhindert ungültige Sessions
- NetworkClient & GoogleBooksClient kapseln Remote-Requests
- DataService dient als zentraler CRUD- und Fallback-Layer

**EN:**
Local repositories abstract SwiftData access and validate session persistence; network clients wrap Google Books APIs;
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
- Text-to-Speech & SwiftData-Tests zeigten, wo Simulator-Timing, AVFoundation und Persistence-Lifecycles bewusst stabilisiert werden müssen.
- Kleine, reviewbare PRs halten MVP-Hardening nachvollziehbar und revertierbar.

**EN:**
- Implementing repository-based search connected networking, DTO mapping, and local persistence.
- StatsService aggregation logic proved how services offload logic from view models.
- Design tokens kept UI modes consistent and prevented duplication.
- TTS and SwiftData tests showed where simulator timing, AVFoundation, and persistence lifecycles need explicit stabilization.
- Small reviewable pull requests kept MVP hardening explainable and reversible.

---

## 🚦 Projektumfang · Product Scope

**Stabilisiert und review-ready:**
- Library-, Book-Detail-, Session-, History-, Stats-, Goals- und Focus-Flows.
- SwiftData-basierte Persistenz für Bücher, Sessions und aktive Ziele.
- Google-Books-gestützte Suche mit Repository-/DTO-Schicht.
- Lokalisierte UI-Texte, Accessibility-Labels und reduzierte Debug-Ausgaben.
- Unit-Test-Baseline plus GitHub Actions für Pull Requests und `main`.

**Bewusst nicht finalisiert:**
- Vollständiger Offline-Discover-Modus.
- Vollständiger App-Store-Release-Prozess mit Signierung, Datenschutztexten und Store-Metadaten.
- Breite UI-Test-Suite in CI; UI-Flows bleiben gezielt/lokal, weil sie auf Simulatoren deutlich fragiler sind.

---

## 🧪 Teststrategie

**Getestete Kernmodule:**
- LocalSessionRepository → validiert Session-Persistenz, Eingaben und Idempotenz
- StatsService → aggregiert Lesezeit deterministisch
- StatsViewModel & ReadingHistoryViewModel → sichern Sichtbarkeit gespeicherter Sessions
- SpeechService → testet Start/Stop-Lifecycle mit simulatorrobuster Warte-Logik
- AppFormatter → prüft lokalisierte Texte & VoiceOver-Kompatibilität
- ReadingGoalsViewModel → erstellt und aktualisiert aktive Ziele robust
- BookDetailViewModel → speichert Sessions mit Erfolg-/Fehlerfeedback

> Fokus: deterministische Kernlogik, In-Memory-SwiftData-Tests und UI-Smokes für zentrale Flows.
> Hinweis: Testausführung erfolgt über Xcode/Xcodebuild; lokale Toolchain-Konfiguration kann vorausgesetzt sein.

**GitHub Actions:**
- Pull Requests nach `main` führen automatisch die Unit-Test-Suite aus.
- Pushes auf `main` validieren den gemergten Stand erneut.
- Der Workflow wählt dynamisch einen verfügbaren iPhone-Simulator auf dem Runner aus.
- UI-Tests bleiben bewusst lokal/gezielt, da Simulator-UI-Flows in CI langsamer und fragiler sind.

```bash
SIMULATOR_ID="$(
  xcrun simctl list devices available |
  awk -F '[()]' '/iPhone/ { print $2; exit }'
)"

xcodebuild test \
  -project ReadRhythm/ReadRhythm.xcodeproj \
  -scheme ReadRhythm \
  -destination "id=${SIMULATOR_ID}" \
  -parallel-testing-enabled NO \
  -only-testing:ReadRhythmTests
```

---

## 🔧 Future Improvements

**DE:**
- DataService & LocalBookRepository zusammenführen, um doppelte Logik zu vermeiden.
- DiscoverViewModel-Dependencies explizit injizieren, um Tests zu vereinfachen.
- Fehlerhandling verbessern (kein `try!`, klare Propagierung).
- Debounce- oder Cancel-Logik für Suchfeld einführen.  
- Persistenten Discover-Feed-Cache als echten Offline-Fallback reaktivieren oder README/UI klar darauf verzichten lassen.
- Optional: UI-Tests weiter reduzieren oder gezielt stabilisieren, damit CI dauerhaft schnell bleibt.

**EN:**
- Consolidate DataService & LocalBookRepository to eliminate duplication.
- Inject DiscoverViewModel dependencies explicitly to ease testing.
- Replace `try!` with safe error propagation.
- Add debouncing or cancellation to search task.
- Reactivate the persistent Discover feed cache as a real offline fallback or keep the product copy focused on saved books.
- Optionally reduce or stabilize UI tests further so CI remains fast and reliable.

---

## 🧩 Tech Stack

- SwiftUI
- SwiftData
- Swift Charts
- Google Books API
- MVVM + Repository Pattern
- Unit Tests (deterministische Kernlogik)
- GitHub Actions CI

---

## 💼 Recruiter Highlights

- Saubere MVVM-Architektur mit klaren Repository- & Service-Layern
- Unit-Tests für Session-Persistenz, Book Detail, Stats, History, Speech und Goals
- GitHub Actions validiert Pull Requests und `main` automatisch
- Design Tokens, i18n & Accessibility konsistent umgesetzt  
- MVP-Hardening mit klaren, kleinen und testbaren Verbesserungen dokumentiert
- Portfolio-ready als SwiftUI/SwiftData-Projekt mit nachvollziehbaren Produktentscheidungen

---

## 🔐 Setup

**Voraussetzungen:**
- macOS mit Xcode 16+.
- iOS Simulator mit iOS 17+.
- Keine externen API-Keys erforderlich; Discover nutzt öffentliche Google-Books-Endpunkte.

**Lokal starten:**
1. Repository klonen.
2. `ReadRhythm/ReadRhythm.xcodeproj` in Xcode öffnen.
3. Scheme `ReadRhythm` auswählen.
4. iPhone-Simulator mit iOS 17+ wählen.
5. Build & Run.

**Unit-Tests lokal ausführen:**

```bash
xcodebuild test \
  -project ReadRhythm/ReadRhythm.xcodeproj \
  -scheme ReadRhythm \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -parallel-testing-enabled NO \
  -only-testing:ReadRhythmTests
```

---

## 🤝 Kontakt / Contact

**Minh Khoi Ha**
📍 Mobile App Developer (iOS · SwiftUI)
🔗 LinkedIn: https://www.linkedin.com/in/minh-khoi-ha
🔗 GitHub: https://github.com/KhoiiHa

---

<h3 align="center">📚 ReadRhythm – Read. Listen. Focus.</h3>
<p align="center"><em>Built with SwiftUI · SwiftData · Swift Charts.</em></p>
