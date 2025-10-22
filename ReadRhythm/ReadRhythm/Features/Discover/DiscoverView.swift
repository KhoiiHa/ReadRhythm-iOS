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
    @StateObject private var viewModel = DiscoverViewModel()

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
                }

                // Lokaler Fallback / kuratierte Sektionen (bleiben wie gehabt)
                if allBooks.isEmpty && viewModel.results.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    // Sektion 1: Empfohlen
                    DiscoverSectionHeader(
                        titleKey: "discover.section.recommended",
                        showSeeAll: true,
                        seeAllDestination: AnyView(
                            DiscoverAllView(searchText: viewModel.searchQuery, category: (nil as DiscoverCategory?))
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
                            DiscoverAllView(searchText: viewModel.searchQuery, category: (nil as DiscoverCategory?))
                        )
                    )
                    horizontalBooks(libraryVisible)

                    // Sektion 3: Trending
                    let trendingVisible = Array(allBooks.shuffled().prefix(8))
                    DiscoverSectionHeader(
                        titleKey: "discover.section.trending",
                        showSeeAll: allBooks.count > 8,
                        seeAllDestination: AnyView(
                            DiscoverAllView(searchText: viewModel.searchQuery, category: (nil as DiscoverCategory?))
                        )
                    )
                    horizontalBooks(trendingVisible)
                }
            }
            .padding(.vertical, AppSpace._16)
        }
        .background(AppColors.Semantic.bgPrimary)
        .navigationTitle(Text(LocalizedStringKey("rr.tab.discover")))
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("discover.view")
        .onAppear {
            // Lokale Library laden (für Fallback & "aus deiner Library")
            viewModel.loadBooks(from: modelContext)
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
                // future: filters sheet
            } label: {
                Image(systemName: "slider.horizontal.3")
            }
            .buttonStyle(.plain)
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
                BookCoverCard(title: book.title, author: book.authors, coverURL: book.thumbnailURL, coverAssetName: nil)
                    .accessibilityIdentifier("discover.result.\(book.id)")
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
                        DiscoverDetailView(book: book)
                    } label: {
                        BookCoverCard(title: book.title, author: book.author, coverURL: nil, coverAssetName: nil)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
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
}
