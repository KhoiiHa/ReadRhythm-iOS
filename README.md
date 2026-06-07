<p align="center">
  <img src="https://res.cloudinary.com/dpaehynl2/image/upload/v1763816743/ReadRhythm_AppIcon_512_pdlw4f.png" width="200" alt="ReadRhythm Logo"/>
</p>

# 📚 ReadRhythm – SwiftUI Reading & Listening Tracker

![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-blue?logo=swift&logoColor=white)
![SwiftData](https://img.shields.io/badge/SwiftData-Ready-orange)
![MVVM](https://img.shields.io/badge/Architecture-MVVM-green)
![iOS17](https://img.shields.io/badge/Target-iOS_17+-lightgrey)
![QA](https://img.shields.io/badge/Tests-Core_Coverage-success)
![Status](https://img.shields.io/badge/Phase-MVP_Hardening-blueviolet)

> Eine minimalistische Reading-App, die Fortschritt sichtbar macht –  
> gebaut mit SwiftUI, SwiftData & Swift Charts für Fokus statt Overload.

> *„Track your reading habits, visualize your progress, and rediscover the joy of mindful reading.“*  
> Developed as part of my iOS Portfolio Project · SwiftUI · MVVM · SwiftData · Swift Charts

---

## 🌍 Projektübersicht · Project Overview

**DE:**  
ReadRhythm ist eine iOS-App, die Lesen und Hören in einer ruhigen SwiftUI-Oberfläche vereint –  
von Bibliotheksverwaltung über Discover-Empfehlungen bis hin zu Statistiken, Zielen und Focus Mode für konzentrierte Sessions.  

**EN:**  
ReadRhythm blends reading and listening into a calm SwiftUI experience,  
covering library management, discovery feeds, goal tracking, and a focus timer for deep-work sessions.

---

## ✨ Hauptfeatures · Key Features

### 📚 Bibliothek / Library
- @Query-gestützte Listen mit SwiftData-Integration  
- Swipe-to-Delete, Add-Sheet, Toast-Feedback  
- ViewModel entkoppelt CRUD-Logik und UI-Zustand  

**EN:**  
SwiftData-backed lists with swipe deletion and add sheet; dedicated view models handle CRUD logic and toast messaging.

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

### 🧘‍♀️ Ziele & Fokus / Goals & Focus
- Progress-Ring mit Haptics und Edit-Sheet  
- Focus Mode Timer speichert Sitzungen automatisch als Sessions  
- Motivationsfeedback durch visuelle Interaktionen  

**EN:**  
Progress ring with haptics and editing sheet; focus timer auto-saves reading sessions and provides visual feedback.

---

### ⚙️ Settings & Theming
- Globaler Settings-Service steuert Theme & Sprache  
- SwiftData-Container + EnvironmentObjects  
- i18n-kompatible Texte und klare App-Konfiguration

---

## 🧩 Architekturüberblick · Architecture Overview

**DE:**  
Die App nutzt **MVVM** mit einem gemeinsamen SwiftData-Container (`PersistenceController.shared`).  
Tabs reichen den ModelContext weiter, Repositories kapseln CRUD-Logik für Bücher und Sessions.  
ViewModels koordinieren Datenflüsse zwischen Services (Library, Discover, Stats),  
wodurch Views reaktiv, testbar und sauber formatiert bleiben.  

**EN:**  
The app adopts **MVVM** with a shared SwiftData container. Tabs pass the model context,  
repositories encapsulate CRUD logic for books and sessions, and view models marshal  
data flows between services to keep views reactive and testable.

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

**DE:**  
Farben, Typografie-, Spacing-, Radius- und Schatten-Tokens sind zentral dokumentiert  
und werden in Komponenten wie StatsCard, Tabs und Toasts konsistent wiederverwendet.  

**EN:**  
Color, typography, spacing, radius, and shadow tokens live in dedicated files  
and power reusable components across the UI.

> **Designziel:** „Ruhig, fokussiert, lesbar“ – inspiriert von modernen Reading Apps auf Behance.  

> 🎨 **UI/UX-Inspiration:**  
> Das visuelle Konzept wurde inspiriert von der hervorragenden  
> [Reading App Case Study (UI/UX Design) auf Behance](https://www.behance.net/gallery/182903381/Reading-App-Case-Study-UIUX-Design).  
> Diese Arbeit verdient Credits – sie zeigt, wie Design und Lesefluss in Einklang gebracht werden können.

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

## 🧪 Teststrategie & Qualitätssicherung

**Getestete Kernmodule:**  
- LocalSessionRepository → validiert Idempotenz  
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

- **SwiftUI + SwiftData:** native UI- und Persistenzschicht  
- **Swift Charts:** Visualisierung & Accessibility  
- **Repository & Services:** lokalisierte Logik + Abstraktion  
- **Networking:** Google Books API via NetworkClient  
- **Tests:** In-Memory-Container, deterministische Kernlogik  

---

## 💼 Recruiter Highlights

- Saubere MVVM-Architektur mit klaren Repository- & Service-Layern  
- Unit-Tests für Stats, Speech, Goals und Session-Persistenz mit deterministischem Verhalten
- Design Tokens, i18n & Accessibility konsistent umgesetzt  
- MVP-Hardening mit klaren, kleinen und testbaren Verbesserungen dokumentiert

---

## 💡 Setup

1. Repository klonen  
2. Öffne `ReadRhythm.xcodeproj` in **Xcode 16+**  
3. Zielgerät: **iOS 17+**  
4. Build & Run

---

## 🙌 Credits

**DE:**  
Google Books API für Discover-Daten, umgesetzt über einen eigenen BooksAPIClient und NetworkClient.  

**EN:**  
Google Books API powers the discovery feed via a lightweight NetworkClient wrapper.

---

## 💬 Autor

**Minh Khoi Ha**  
📍 iOS Developer · Product Strategist · Portfolio-Projekt *ReadRhythm*  
📧 Kontakt auf Anfrage  

---

© 2025 Minh Khoi Ha · Projekt: ReadRhythm
