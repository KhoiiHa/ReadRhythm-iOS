//
//  DiscoverView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import SwiftUI
import SwiftData

/// Kontext → Warum → Wie
/// - Kontext: Discover zeigt kuratierten Einstieg ins Erkunden.
/// - Warum: Vertikaler Hauptfluss + horizontale Carousels pro Sektion sind effizient und vertraut.
/// - Wie: Reusable Header + BookCoverCard, @Query als Datenquelle (MVP), i18n/A11y konsistent.
struct DiscoverView: View {
    // MVP-Datenquelle: alle Bücher, später durch Service/Feeds ersetzbar
    @Query(sort: \BookEntity.title, order: .forward)
    private var allBooks: [BookEntity]

    // MARK: - Environment / ViewModel
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: DiscoverViewModel
    @State private var repository: (any BookRepository)?
    @State private var didAutoLoad = false
    @State private var showFilterSheet = false

    /// true, wenn der Nutzer aktiv filtert/sucht (Kategorie gewählt oder Text eingegeben)
    private var hasActiveFilter: Bool {
        let q = viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return viewModel.selectedCategory != nil || !q.isEmpty
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpace._16) {
                // Suche
                searchBar

                // Kategorie-Chips
                categoryChips

                // Zustand: Laden / Fehler / Ergebnisse
                if viewModel.isLoading {
                    ProgressView(LocalizedStringKey("discover.loading"))
                        .frame(maxWidth: .infinity, minHeight: 120)
                } else if let msg = viewModel.errorMessage {
                    Text(LocalizedStringKey(msg))
                        .font(.footnote)
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .padding(.horizontal, AppSpace._16)
                } else if !viewModel.results.isEmpty {
                    DiscoverSectionHeader(
                        titleKey: "discover.section.results",
                        showSeeAll: false
                    )
                    resultsList(viewModel.results)
                } else if !viewModel.isLoading && viewModel.results.isEmpty && hasActiveFilter {
                    // Keine Treffer für aktive Suche / Kategorie
                    noResultsForCategory
                }

                // Lokaler Fallback / kuratierte Sektionen:
                // nur zeigen, wenn der Nutzer NICHT gerade filtert / sucht
                if !hasActiveFilter {
                    if allBooks.isEmpty && viewModel.results.isEmpty && !viewModel.isLoading {
                        emptyState
                    } else {
                        // Sektion 1: Empfohlen
                        DiscoverSectionHeader(
                            titleKey: "discover.section.recommended",
                            showSeeAll: true,
                            seeAllDestination: AnyView(
                                DiscoverAllView(
                                    initialSearchText: viewModel.searchQuery,
                                    initialCategory: nil,
                                    repository: repository
                                )
                            )
                        )
                        let recommended = Array(allBooks.prefix(8))
                        horizontalBooks(recommended)

                        // Sektion 2: Aus deiner Library
                        let libraryVisible = Array(allBooks.suffix(8))
                        DiscoverSectionHeader(
                            titleKey: "discover.section.fromLibrary",
                            showSeeAll: allBooks.count > 8,
                            seeAllDestination: AnyView(
                                DiscoverAllView(
                                    initialSearchText: viewModel.searchQuery,
                                    initialCategory: nil,
                                    repository: repository
                                )
                            )
                        )
                        horizontalBooks(libraryVisible)

                        // Sektion 3: Trending
                        let trendingVisible = Array(allBooks.shuffled().prefix(8))
                        DiscoverSectionHeader(
                            titleKey: "discover.section.trending",
                            showSeeAll: allBooks.count > 8,
                            seeAllDestination: AnyView(
                                DiscoverAllView(
                                    initialSearchText: viewModel.searchQuery,
                                    initialCategory: nil,
                                    repository: repository
                                )
                            )
                        )
                        horizontalBooks(trendingVisible)
                    }
                }
            }
            .padding(.vertical, AppSpace._16)
        }
        .background(AppColors.Semantic.bgPrimary)
        .navigationTitle(Text(LocalizedStringKey("rr.tab.discover")))
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("discover.view")
        .overlay(alignment: .bottom) {
            if let key = viewModel.toastText {
                Text(LocalizedStringKey(key))
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(AppColors.Semantic.bgElevated)
                            .overlay(Capsule().stroke(AppColors.Semantic.borderMuted, lineWidth: 1))
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
        .sheet(isPresented: $showFilterSheet) {
            VStack(spacing: AppSpace._16) {
                HStack {
                    // TODO: i18n folgt in Phase 11 (Bonus-Feature)
                    Text("Filter")
                        .font(.headline)
                    Spacer()
                    Button {
                        showFilterSheet = false
                    } label: {
                        // TODO: i18n folgt in Phase 11 (Bonus-Feature)
                        Text("Fertig")
                            .font(.subheadline)
                            .bold()
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("discover.filter.done")
                }
                .padding(.horizontal, AppSpace._16)
                .padding(.top, AppSpace._16)

                Divider()

                VStack(alignment: .leading, spacing: AppSpace._12) {
                    // TODO: i18n folgt in Phase 11 (Bonus-Feature)
                    Text("Aktive Kategorie")
                        .font(.footnote)
                        .foregroundStyle(AppColors.Semantic.textSecondary)

                    if let cat = viewModel.selectedCategory {
                        HStack(spacing: AppSpace._8) {
                            Image(systemName: cat.systemImage)
                            Text(cat.displayName)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, AppSpace._12)
                        .padding(.vertical, AppSpace._8)
                        .background(
                            Capsule().fill(AppColors.Semantic.bgElevated)
                                .overlay(
                                    Capsule().stroke(AppColors.Semantic.borderMuted, lineWidth: 1)
                                )
                        )
                    } else {
                        // TODO: i18n folgt in Phase 11 (Bonus-Feature)
                        Text("Keine Kategorie ausgewählt")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.Semantic.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpace._16)

                Divider()

                VStack(spacing: AppSpace._12) {
                    Button {
                        // Reset: Kategorie weg, Suchfeld leeren, lokale Fallback-Sektionen zeigen
                        viewModel.searchQuery = ""
                        viewModel.applyFilter(category: nil)
                        showFilterSheet = false
                        #if DEBUG
                        print("🧼 [DiscoverView] filters reset")
                        #endif
                    } label: {
                        Label(
                            LocalizedStringKey("discover.empty.resetFilters"),
                            systemImage: "arrow.counterclockwise"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.Semantic.tintPrimary)
                    .accessibilityIdentifier("discover.filter.reset")
                }
                .padding(.horizontal, AppSpace._16)

                Spacer()
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if repository == nil {
                let localRepository = LocalBookRepository(context: modelContext)
                repository = localRepository
                viewModel.updateRepository(localRepository)
            }

            // Lokale Library laden (für Fallback & "aus deiner Library")
            viewModel.loadBooks()

            // Erste API-Ladung nur einmal anstoßen.
            if !didAutoLoad {
                didAutoLoad = true
                // Kategorien-Start (z. B. Achtsamkeit & Balance)
                viewModel.applyFilter(category: .mindfulness)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: AppSpace._8) {
            Image(systemName: "magnifyingglass")
            TextField(text: $viewModel.searchQuery) {
                Text(LocalizedStringKey("discover.search.placeholder"))
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onSubmit { viewModel.applySearch() }
            Spacer()
            Button {
                #if DEBUG
                print("🔬 [DiscoverView] filter tapped")
                #endif
                showFilterSheet = true
            } label: {
                Image(systemName: "slider.horizontal.3")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("discover.filterButton")
        }
        .font(.subheadline)
        .padding(.horizontal, AppSpace._16)
        .frame(height: 44)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: AppRadius.m)
                .fill(AppColors.Semantic.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.m)
                        .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, AppSpace._16)
        .accessibilityIdentifier("discover.searchBar")
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpace._8) {
                ForEach(DiscoverCategory.ordered, id: \.id) { cat in
                    Button {
                        // Toggle selection
                        let newSelection: DiscoverCategory? = (viewModel.selectedCategory == cat) ? nil : cat
                        viewModel.applyFilter(category: newSelection)
                    } label: {
                        let isActive = (viewModel.selectedCategory == cat)
                        HStack(spacing: AppSpace._6) {
                            Image(systemName: cat.systemImage)
                            Text(cat.displayName)
                        }
                        .font(.footnote)
                        .padding(.horizontal, AppSpace._12)
                        .padding(.vertical, AppSpace._8)
                        .background(Capsule().fill(AppColors.Semantic.bgElevated))
                        .overlay(
                            Capsule().stroke(isActive ? AppColors.brandPrimary : AppColors.Semantic.borderMuted, lineWidth: 1)
                        )
                        .accessibilityIdentifier("discover.chip.\(cat.id)")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, AppSpace._16)
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("discover.chips")
    }

    private func resultsList(_ items: [RemoteBook]) -> some View {
        LazyVStack(spacing: AppSpace._12) {
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
                            viewModel.addToLibrary(from: book)
                        }
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.cancelToast()
                })

                Divider().opacity(0.1)
            }
        }
        .padding(.horizontal, AppSpace._16)
    }

    private func horizontalBooks(_ books: [BookEntity]) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: AppSpace._12) {
                ForEach(books) { book in
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
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.cancelToast()
                    })
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .accessibilityIdentifier("discover.carousel.books.hstack")
        }
        .contentMargins(.horizontal, AppSpace._16)
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("discover.carousel.books")
    }

    private var emptyState: some View {
        VStack(spacing: AppSpace._16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.Semantic.textSecondary)
            Text(LocalizedStringKey("discover.empty.title"))
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
            Text(LocalizedStringKey("discover.empty.subtitle"))
                .font(.subheadline)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpace._16)
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .background(AppColors.Semantic.bgPrimary)
        .accessibilityIdentifier("discover.empty")
    }
    
    /// Spezifischer leerer Zustand: aktive Suche / Kategorie liefert nichts
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

            // Optional später: Button "Filter zurücksetzen"
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.horizontal, AppSpace._16)
        .accessibilityIdentifier("discover.empty.category")
    }
    
    // MARK: - Init
    init(repository: (any BookRepository)? = nil) {
        // Repository wird optional injiziert.
        // Fallback: wir erstellen eine LocalBookRepository mit dem aktuellen ModelContext.
        // Wichtig: Wir dürfen hier nicht auf PersistenceController.shared.mainContext zugreifen,
        // weil DiscoverView selbst bereits @Environment(\.modelContext) nutzt (MainActor-gebunden).
        //
        // Lösung:
        // - repository-Argument, falls gesetzt: benutzen
        // - sonst legen wir im init einen Platzhalter nil an; der echte Context wird dann in onAppear gesetzt
        //
        // Das verhindert MainActor-Warnings im Init.
        self._repository = State(initialValue: repository)
        if let injected = repository {
            self._viewModel = StateObject(wrappedValue: DiscoverViewModel(repository: injected))
        } else {
            // Temporärer Placeholder, wird in onAppear mit realem Repository + Context versorgt.
            self._viewModel = StateObject(wrappedValue: DiscoverViewModel(repository: LocalBookRepository(context: PersistenceController.shared.mainContext)))
        }
    }
}

