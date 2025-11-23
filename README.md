<p align="center">
  <img src="https://res.cloudinary.com/dpaehynl2/image/upload/v1763909607/ReadRhythm_Banner_1600x900_v2qzle.png"
       alt="ReadRhythm Banner"
       width="640" />
</p>

<h1 align="center">📚 ReadRhythm – iOS Reading & Listening Tracker</h1>
<h3 align="center"><em>Track. Focus. Grow. – Built with SwiftUI · SwiftData · Swift Charts</em></h3>

<p align="center">
  <img src="https://res.cloudinary.com/dpaehynl2/image/upload/v1763816743/ReadRhythm_AppIcon_512_pdlw4f.png"
       alt="ReadRhythm Logo"
       width="140" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/SwiftUI-Framework-blue?logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/SwiftData-Ready-orange" />
  <img src="https://img.shields.io/badge/Architecture-MVVM-green" />
  <img src="https://img.shields.io/badge/Target-iOS_17+-lightgrey" />
  <img src="https://img.shields.io/badge/Tests-Core_Stable-success" />
  <img src="https://img.shields.io/badge/Phase-Code_Freeze_✅-blueviolet" />
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

### 🔎 Discover & Empfehlungen / Discover & Recommendations
- Kategorie-Chips, Suchfeld, Google Books API  
- Repository-Layer orchestriert Cache, API & SwiftData  
- Offline-Zugriff auf gespeicherte Ergebnisse

**EN:** Repository coordinates search, caching and persistence using Google Books + SwiftData.

---

### 📊 Statistiken / Stats & Insights
- Swift Charts für Minuten/Tag, Streaks & Gesamtwerte  
- StatsService aggregiert Sessions deterministisch  
- Debug-Seeding für Tests

**EN:** Swift Charts visualizing reading minutes, streaks and daily trends.

---

### 🧘‍♀️ Ziele & Fokus / Goals & Focus Mode
- Progress Ring mit Haptics  
- Fokus-Timer speichert Sessions automatisch  
- Klarer, reduzierter „Deep Work“-Flow

---

### ⚙️ Settings & Theming
- Globaler SettingsService  
- i18n vorbereitet  
- Debug-Reset für Showcase-Daten (Demo Mode)

---

## 🧩 Architekturüberblick · Architecture Overview

### 🇩🇪  
ReadRhythm nutzt **MVVM** mit einem gemeinsamen SwiftData-Container (`PersistenceController.shared`).  
Repositories kapseln zentrale Logik, ViewModels koordinieren Data-Flows und halten die Views sauber & testbar.

### 🇬🇧  
Based on **MVVM** with a shared SwiftData container. Repositories abstract CRUD logic and view models marshal service flows cleanly.

---

### 🧠 Repository & Services
- Lokale Repositories: Book, Session  
- Network-Schicht: GoogleBooksClient  
- Stale-While-Revalidate Strategie  
- DataService als zentrales Fallback-Layer

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

### 🇩🇪  
- Repository-Muster für Stabilität & Offline-Fähigkeit  
- Deterministische Stats-Logik  
- i18n, A11y & Design Tokens strukturiert umgesetzt  
- Swift Charts + SwiftData als moderne Kombi

### 🇬🇧  
- Repository pattern improved stability & offline behavior  
- Deterministic stats logic  
- Strong investment in i18n, A11y and design tokens  

---

## 🧪 Teststrategie

### Getestete Module
- `LocalSessionRepository` – Idempotenz  
- `StatsService` – deterministische Aggregation  
- `SpeechService` – Lifecycle  
- `AppFormatter` – Lokalisierung & VoiceOver

---

## 🔧 Future Improvements

🇩🇪 DataService & BookRepository konsolidieren · Debounce für Suche · Fehler-Handling verfeinern  
🇬🇧 Consolidate repositories · Add debouncing · Improve error propagation

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

- Saubere, moderne Architektur (MVVM + Repositories + SwiftData)  
- Unit Tests & deterministische Statistiken  
- Ruhiges, professionelles UI  
- Ready für Store- & Portfolio-Präsentation

---

## 🔐 Setup

1. Repo klonen  
2. `ReadRhythm.xcodeproj` öffnen (Xcode 16+)  
3. Build & Run  
4. Demo-Daten laden automatisch

---

## 🤝 Kontakt / Contact

** Minh Khoi Ha**  
📍 Mobile App Developer (iOS · SwiftUI)  
🔗 LinkedIn: https://www.linkedin.com/in/minh-khoi-ha  
🔗 GitHub: https://github.com/KhoiiHa

---

<h3 align="center">📚 ReadRhythm – Read. Listen. Focus.</h3>
<p align="center"><em>Built with SwiftUI · SwiftData · Swift Charts.</em></p>
