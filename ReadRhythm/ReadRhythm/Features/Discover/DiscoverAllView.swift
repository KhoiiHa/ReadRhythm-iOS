//
//  DiscoverAllView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI
import SwiftData

#if os(iOS)
import UIKit
#endif

/// Vollansicht für Discover:
/// - Zeigt Remote-Ergebnisse aus der API (viewModel.results)
/// - Zeigt gespeicherte Bücher aus SwiftData als Fallback (allBooks)
/// - Ermöglicht Speichern via "+"
/// - Bietet Suche + Kategoriechips + Sortierung
///
/// Diese View hängt an DiscoverViewModel, das sowohl die API-State hält
/// als auch die lokale Speicherlogik.
struct DiscoverAllView: View {

    // Startzustand, den wir vom Caller (z. B. DiscoverView) übernehmen wollen.
    // Beispiel: User hat schon gesucht oder eine Kategorie getappt.
    let initialSearchText: String
    let initialCategory: DiscoverCategory?

    // SwiftData-Kontext für Laden/Speichern
    @Environment(\.modelContext) private var modelContext

    // Alle lokal gespeicherten Bücher, via SwiftData-Query
    @Query(sort: [SortDescriptor(\BookEntity.title, order: .forward)])
    private var allBooksQuery: [BookEntity]

    // Unser Discover-ViewModel
    // Wichtig: Wir behalten @StateObject, damit dieses ViewModel in dieser View "lebt".
    // Für Bindings zu @Published-Properties verwenden wir unten eigene Binding-Wrapper.
    @StateObject private var viewModel: DiscoverViewModel
    @State private var repository: (any BookRepository)?

    init(
        initialSearchText: String,
        initialCategory: DiscoverCategory?,
        repository: (any BookRepository)? = nil
    ) {
        self.initialSearchText = initialSearchText
        self.initialCategory = initialCategory
        self._repository = State(initialValue: repository)
        let initialRepository = repository ?? LocalBookRepository(context: PersistenceController.shared.mainContext)
        self._viewModel = StateObject(wrappedValue: DiscoverViewModel(repository: initialRepository))
    }

    // Sortierung für das lokale Grid (Fallback-Section)
    private enum SortOption: String, CaseIterable, Identifiable {
        case title, author, date
        var id: String { rawValue }
    }
    @State private var sortOption: SortOption = .title

    // MARK: - Computed Helpers

    /// Gibt true zurück, wenn gerade eine aktive Suche/Kategorie gefiltert wird.
    private var hasActiveFilter: Bool {
        let q = viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return viewModel.selectedCategory != nil || !q.isEmpty
    }

    /// Bindung für das Suchfeld, damit TextField nicht über `$viewModel.searchQuery`
    /// meckert (was bei @StateObject in manchen SwiftUI-Versionen Probleme macht).
    private var searchBinding: Binding<String> {
        Binding(
            get: { viewModel.searchQuery },
            set: { viewModel.searchQuery = $0 }
        )
    }

    /// Gefilterte Bücher aus SwiftData nach Suchtext/Kategorie.
    /// (Das ist deine Offline/Library-Fallback-Sektion)
    private var filteredBooks: [BookEntity] {
        // 1. Suchfilter
        let trimmed = viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        let base: [BookEntity]
        if trimmed.isEmpty {
            base = allBooksQuery
        } else {
            let q = trimmed.lowercased()
            base = allBooksQuery.filter { b in
                b.title.lowercased().contains(q)
                || (b.author.lowercased().contains(q))
            }
        }

        // 2. Kategorie-Filter (DiscoverCategory)
        guard let cat = viewModel.selectedCategory else {
            return base
        }

        switch cat {
        case .fictionRomance:
            return base.filter {
                $0.title.localizedCaseInsensitiveContains("novel")
                || $0.title.localizedCaseInsensitiveContains("story")
                || $0.title.localizedCaseInsensitiveContains("love")
            }

        case .mindfulness, .philosophy:
            return base.filter {
                titleIn($0, matchesAnyOf: ["mind", "meditation", "philosophy", "zen"])
            }

        case .selfHelp, .psychology:
            return base.filter {
                titleIn($0, matchesAnyOf: ["habit", "better", "change", "think", "psychology"])
            }

        case .creativity, .wellness:
            return base.filter {
                titleIn($0, matchesAnyOf: ["creative", "art", "design", "health", "wellness"])
            }
        }
    }

    /// Gefilterte Bücher zusätzlich sortiert für Anzeige im lokalen Grid.
    private var displayedBooks: [BookEntity] {
        let base = filteredBooks
        switch sortOption {
        case .title:
            return base.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .author:
            return base.sorted {
                ($0.author).localizedCaseInsensitiveCompare($1.author) == .orderedAscending
            }
        case .date:
            // Wir haben kein persistiertes createdAt Feld mehr – behalte Reihenfolge aus `filteredBooks` bei.
            return base
        }
    }

    /// Navigationstitel: wenn Kategorie aktiv → deren i18n-Key, sonst Standardtitel.
    private var navTitleKey: LocalizedStringKey {
        if let cat = viewModel.selectedCategory {
            // Wichtig: rawValue ist der i18n-Key, nicht der sichtbare Name
            return LocalizedStringKey(cat.rawValue)
        } else {
            return LocalizedStringKey("discover.all.title")
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace._16) {

                // Sucheingabe
                searchBar

                // Horizontale Kategorie-Chips
                categoryChips

                // API-Resultate / Ladezustände / Fehleranzeige
                if viewModel.isLoading {
                    ProgressView(LocalizedStringKey("discover.loading"))
                        .frame(maxWidth: .infinity, minHeight: 120)

                } else if let msg = viewModel.errorMessage {
                    Text(LocalizedStringKey(msg))
                        .font(.footnote)
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .padding(.horizontal, AppSpace._16)

                } else if !viewModel.results.isEmpty {
                    resultsGrid(viewModel.results)
                        .padding(.horizontal, AppSpace._16)

                } else if !viewModel.isLoading,
                          viewModel.results.isEmpty,
                          hasActiveFilter {
                    noResultsForCategory
                        .padding(.horizontal, AppSpace._16)
                }

                // Lokaler Fallback: deine gespeicherten Bücher
                if !hasActiveFilter {
                    grid
                        .padding(.horizontal, AppSpace._16)

                    if displayedBooks.isEmpty {
                        emptyLibraryFallback
                    }
                }

                Spacer(minLength: AppSpace._16)
            }
            .padding(.top, AppSpace._16)
        }
        .screenBackground()
        .navigationTitle(Text(navTitleKey))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                sortMenu
            }
        }
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("discover.all.view")
        .overlay(alignment: .bottom) {
            // Kleiner Toast unten ("Hinzugefügt", "Schon vorhanden", "Fehler")
            if let key = viewModel.toastText {
                Text(LocalizedStringKey(key))
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.Semantic.bgCard)
                            .overlay(
                                Capsule()
                                    .stroke(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)
                            )
                    )
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.toastText)
                    .accessibilityIdentifier("toast.\(key)")
                    .accessibilityElement(children: .combine)
            }
        }
        .onDisappear {
            viewModel.cancelToast()
        }
        .onAppear {
            if repository == nil {
                let localRepository = LocalBookRepository(context: modelContext)
                repository = localRepository
                viewModel.updateRepository(localRepository)
            }

            // 1. Lokale gespeicherte Bücher reinziehen (SwiftData)
            viewModel.loadBooks()

            // 2. Initiale Filter-/Sucheinstellungen übernehmen
            viewModel.searchQuery = initialSearchText
            viewModel.applyFilter(category: initialCategory)

            // 3. Falls schon ein Suchstring gesetzt war → Suche auslösen
            if !initialSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.applySearch()
            }
        }
    }

    // MARK: - Subviews

    /// Suchfeld oben
    private var searchBar: some View {
        HStack(spacing: AppSpace._8) {
            Image(systemName: "magnifyingglass")

            TextField(
                text: searchBinding // <- Binding statt $viewModel.searchQuery
            ) {
                Text(LocalizedStringKey("discover.search.placeholder"))
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onSubmit {
                viewModel.applySearch()
            }
            .accessibilityLabel(
                Text(LocalizedStringKey("discover.search.placeholder"))
            )
        }
        .font(.subheadline)
        .padding(.horizontal, AppSpace._16)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.m)
                .fill(AppColors.Semantic.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.m)
                        .stroke(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)
                )
        )
        .padding(.horizontal, AppSpace._16)
        .accessibilityIdentifier("discover.all.search")
    }

    /// Horizontale Kategorie-Chips
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpace._8) {
                ForEach(DiscoverCategory.ordered, id: \.id) { cat in
                    let isActive = (viewModel.selectedCategory == cat)

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            // Toggle-Logik: erneut tippen = abwählen
                            let newSelection: DiscoverCategory? = isActive ? nil : cat
                            viewModel.applyFilter(category: newSelection)
                        }
                    } label: {
                        HStack(spacing: AppSpace._6) {
                            Image(systemName: cat.systemImage)
                            Text(cat.displayName)
                        }
                        .font(.footnote)
                        .padding(.horizontal, AppSpace._12)
                        .padding(.vertical, AppSpace._8)
                        .background(
                            Capsule()
                                .fill(AppColors.Semantic.chipBg)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    isActive
                                    ? AppColors.brandPrimary
                                    : AppColors.Semantic.borderMuted,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("discover.all.chip.\(cat.id)")
                }
            }
            .padding(.horizontal, AppSpace._16)
        }
    }

    /// Grid der API-/Remote-Ergebnisse (Google Books)
    private func resultsGrid(_ items: [RemoteBook]) -> some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 140), spacing: AppSpace._12)],
            spacing: AppSpace._12
        ) {
            ForEach(items, id: \.id) { book in
                NavigationLink {
                    DiscoverDetailView(detail: DiscoverBookDetail(from: book))
                } label: {
                    BookCoverCard(
                        title: book.title,
                        author: book.authorsDisplay,
                        coverURL: book.thumbnailURL,
                        coverAssetName: nil,
                        onAddToLibrary: {
                            #if os(iOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif

                            // Speichern in SwiftData über das ViewModel
                            viewModel.addToLibrary(from: book)
                        }
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("discover.all.result.\(book.id)")
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.cancelToast()
                })
            }
        }
    }

    /// Grid der lokal gespeicherten Bücher (SwiftData Fallback / Library)
    private var grid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 140), spacing: AppSpace._12)],
            spacing: AppSpace._12
        ) {
            ForEach(displayedBooks) { book in
                NavigationLink {
                    BookDetailView(book: book)
                } label: {
                    BookCoverCard(
                        title: book.title,
                        author: book.author,
                        coverURL: nil,
                        coverAssetName: nil,
                        onAddToLibrary: nil
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("discover.all.card.\(book.id)")
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.cancelToast()
                })
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedCategory)
    }

    /// Block, der gezeigt wird, wenn keine gespeicherten Bücher existieren
    /// (also komplett leere Library + kein aktiver Filter)
    private var emptyLibraryFallback: some View {
        VStack(spacing: AppSpace._12) {
            Text(LocalizedStringKey("discover.empty.title"))
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textSecondary)

            Text(LocalizedStringKey("discover.empty.subtitle"))
                .font(.subheadline)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpace._16)

            Button {
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.searchQuery = ""
                    viewModel.applyFilter(category: nil)
                }
            } label: {
                Label(
                    LocalizedStringKey("discover.empty.resetFilters"),
                    systemImage: "arrow.counterclockwise"
                )
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("discover.all.resetFilters")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpace._16)
    }

    /// Kein Treffer für aktive Suche/Kategorie
    private var noResultsForCategory: some View {
        VStack(spacing: AppSpace._16) {
            Image(systemName: "questionmark.book")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.Semantic.textSecondary)

            Text(LocalizedStringKey("discover.empty.noResultsForCategory"))
                .font(.subheadline)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpace._16)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.horizontal, AppSpace._16)
        .accessibilityIdentifier("discover.empty.category")
    }

    /// Sortier-Menü in der Toolbar
    private var sortMenu: some View {
        Menu {
            Picker(
                LocalizedStringKey("discover.sort.title"),
                selection: $sortOption
            ) {
                Text(LocalizedStringKey("discover.sort.byTitle")).tag(SortOption.title)
                Text(LocalizedStringKey("discover.sort.byAuthor")).tag(SortOption.author)
                Text(LocalizedStringKey("discover.sort.byDate")).tag(SortOption.date)
            }
        } label: {
            Label(
                LocalizedStringKey("discover.sort.title.short"),
                systemImage: "arrow.up.arrow.down"
            )
        }
        .accessibilityIdentifier("discover.all.sortMenu")
    }

    // MARK: - Helpers

    /// Kleiner Helper für Kategoriefilter im Fallback (lokale Bücher)
    private func titleIn(_ book: BookEntity, matchesAnyOf parts: [String]) -> Bool {
        parts.contains { p in
            book.title.range(
                of: p,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) != nil
        }
    }
}

#if DEBUG
#Preview("DiscoverAll – Empty (Light, DE)") {
    let models: [any PersistentModel.Type] = ReadRhythmSchemaV2.models
    let schema = Schema(models)
    let container = try! ModelContainer(
        for: schema,
        migrationPlan: ReadRhythmMigrationPlan.self,
        configurations: ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
    )

    NavigationStack {
        DiscoverAllView(
            initialSearchText: "",
            initialCategory: nil,
            repository: MockBookRepository()
        )
    }
    .modelContainer(container)
    .environment(\.locale, .init(identifier: "de"))
    .preferredColorScheme(.light)
}

#Preview("DiscoverAll – Empty (Dark, DE)") {
    let models: [any PersistentModel.Type] = ReadRhythmSchemaV2.models
    let schema = Schema(models)
    let container = try! ModelContainer(
        for: schema,
        migrationPlan: ReadRhythmMigrationPlan.self,
        configurations: ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
    )

    NavigationStack {
        DiscoverAllView(
            initialSearchText: "",
            initialCategory: nil,
            repository: MockBookRepository()
        )
    }
    .modelContainer(container)
    .environment(\.locale, .init(identifier: "de"))
    .preferredColorScheme(.dark)
}
#endif
