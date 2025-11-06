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

    /// Fixe Liste aller Kategorien, entlastet die ForEach-Generics
    private let allCategories: [DiscoverCategory] = DiscoverCategory.ordered

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
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                } else if !viewModel.results.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpace._12) {
                        DiscoverSectionHeader(
                            titleKey: "discover.section.results",
                            showSeeAll: false
                        )
                        resultsList(viewModel.results)
                    }
                    .padding(.top, AppSpace._16)
                    .padding(.horizontal, AppSpace._4)
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
                        let recommended = Array(allBooks.prefix(8))
                        sectionCard {
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
                            horizontalBooks(recommended)
                        }

                        // Sektion 2: Aus deiner Library
                        let libraryVisible = Array(allBooks.suffix(8))
                        sectionCard {
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
                        }

                        // Sektion 3: Trending
                        let trendingVisible = Array(allBooks.shuffled().prefix(8))
                        sectionCard {
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
            }
            .padding(.horizontal, AppSpace._16)
            .padding(.vertical, AppSpace._16)
        }
        .background(AppColors.Semantic.bgScreen)
        .navigationTitle(Text(LocalizedStringKey("rr.tab.discover")))
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("discover.view")
        .overlay(alignment: .bottom) {
            if let key = viewModel.toastText {
                Text(LocalizedStringKey(key))
                    .font(AppFont.caption2())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.Semantic.bgCard)
                            .overlay(Capsule().stroke(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder))
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
            DiscoverFilterView(
                viewModel: viewModel,
                allCategories: allCategories,
                isPresented: $showFilterSheet
            )
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
        .font(AppFont.bodyStandard())
        .frame(height: 44)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: AppRadius.m)
                .fill(AppColors.Semantic.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.m)
                        .stroke(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)
                )
        )
        .accessibilityIdentifier("discover.searchBar")
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpace._8) {
                ForEach(Array(allCategories.enumerated()), id: \.offset) { _, cat in
                    Button {
                        // Toggle selection
                        let newSelection: DiscoverCategory? =
                            (viewModel.selectedCategory == cat) ? nil : cat
                        viewModel.applyFilter(category: newSelection)
                    } label: {
                        let isActive = (viewModel.selectedCategory == cat)

                        HStack(spacing: AppSpace._6) {
                            Image(systemName: cat.systemImage)
                            Text(cat.displayName)
                        }
                        .font(AppFont.caption2())
                        .padding(.horizontal, AppSpace._12)
                        .padding(.vertical, AppSpace._8)
                        .background(Capsule().fill(AppColors.Semantic.chipBg))
                        .overlay(
                            Capsule().stroke(
                                isActive ? AppColors.brandPrimary
                                         : AppColors.Semantic.borderMuted,
                                lineWidth: 1
                            )
                        )
                        .accessibilityIdentifier("discover.chip.\(cat.id)")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpace._16)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("discover.chips")
    }

    private func resultsList(_ items: [RemoteBook]) -> some View {
        let columns = [
            GridItem(.flexible(minimum: 0, maximum: 220), spacing: AppSpace._16),
            GridItem(.flexible(minimum: 0, maximum: 220), spacing: AppSpace._16)
        ]

        return LazyVGrid(columns: columns, spacing: AppSpace._16) {
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
                    .frame(maxWidth: .infinity, alignment: .top)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.cancelToast()
                })
            }
        }
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
                .font(AppFont.headingM())
                .foregroundStyle(AppColors.Semantic.textPrimary)
            Text(LocalizedStringKey("discover.empty.subtitle"))
                .font(AppFont.bodyStandard())
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .accessibilityIdentifier("discover.empty")
    }
    
    /// Spezifischer leerer Zustand: aktive Suche / Kategorie liefert nichts
    private var noResultsForCategory: some View {
        VStack(spacing: AppSpace._16) {
            Image(systemName: "questionmark.book")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.Semantic.textSecondary)

            Text(LocalizedStringKey("discover.empty.noResultsForCategory"))
                .font(AppFont.bodyStandard())
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .multilineTextAlignment(.center)

            // Optional später: Button "Filter zurücksetzen"
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .accessibilityIdentifier("discover.empty.category")
    }
    
    /// Umschließt eine Discover-Sektion (Header + Inhalt) in einer weichen Card,
    /// angelehnt an das Behance-Layout (mehr Weißraum, bgCard, Shadow).
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpace._12) {
            content()
        }
        .padding(AppSpace._16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.l)
                .fill(AppColors.Semantic.bgCard)
                .shadow(
                    color: AppColors.Semantic.shadowColor.opacity(0.18),
                    radius: 10,
                    x: 0,
                    y: 6
                )
        )
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

