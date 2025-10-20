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

    // MARK: Filtering State (MVP)
    @State private var searchText: String = ""
    @State private var selectedCategory: Category? = nil

    enum Category: String, CaseIterable {
        case recent, popular, fiction, nonfiction
    }

    // einfache Dummy-Kategorien, später aus Service/i18n
    private let categories: [LocalizedStringKey] = [
        "discover.cat.recent", "discover.cat.popular", "discover.cat.fiction", "discover.cat.nonfiction"
    ]

    // MARK: Derived Data
    private var filteredBooks: [BookEntity] {
        // 1) Search filter (title/author)
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let base: [BookEntity]
        if trimmed.isEmpty {
            base = allBooks
        } else {
            let q = trimmed.lowercased()
            base = allBooks.filter { b in
                b.title.lowercased().contains(q) || (b.author?.lowercased().contains(q) ?? false)
            }
        }
        // 2) Category filter (simple heuristics for MVP)
        guard let cat = selectedCategory else { return base }
        switch cat {
        case .recent:
            return Array(base.prefix(20))
        case .popular:
            return base.sorted { $0.title < $1.title }
        case .fiction:
            return base.filter { $0.title.localizedCaseInsensitiveContains("novel") || $0.title.localizedCaseInsensitiveContains("story") }
        case .nonfiction:
            return base.filter { titleIn($0, matchesAnyOf: ["guide", "clean", "design", "architecture"]) }
        }
    }

    private func titleIn(_ book: BookEntity, matchesAnyOf parts: [String]) -> Bool {
        let t = book.title
        return parts.contains { p in t.range(of: p, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    }

    private func catTitle(_ c: Category) -> LocalizedStringKey {
        switch c {
        case .recent: return LocalizedStringKey("discover.cat.recent")
        case .popular: return LocalizedStringKey("discover.cat.popular")
        case .fiction: return LocalizedStringKey("discover.cat.fiction")
        case .nonfiction: return LocalizedStringKey("discover.cat.nonfiction")
        }
    }

    var body: some View {
        ScrollView {
            if allBooks.isEmpty {
                emptyState
            } else {
                LazyVStack(alignment: .leading, spacing: AppSpace._16) {
                    // Suche (statisch – Sheet/Route folgt später)
                    searchBar

                    // Filter-Chips (horizontales Scrollen)
                    categoryChips

                    // Sektion 1: Empfohlen (hier: erste N Bücher)
                    DiscoverSectionHeader(
                        titleKey: "discover.section.recommended",
                        showSeeAll: true,
                        seeAllDestination: AnyView(
                            DiscoverAllView(searchText: searchText, category: selectedCategory)
                        )
                    )
                    let books = filteredBooks
                    let visible = Array(books.prefix(8))
                    horizontalBooks(visible)

                    // Sektion 2: Aus deiner Library (hier: letzte N Bücher)
                    let libraryAll = allBooks
                    let libraryVisible = Array(libraryAll.suffix(8))
                    DiscoverSectionHeader(
                        titleKey: "discover.section.fromLibrary",
                        showSeeAll: libraryAll.count > 8,
                        seeAllDestination: AnyView(
                            DiscoverAllView(searchText: searchText, category: .recent)
                        )
                    )
                    horizontalBooks(libraryVisible)

                    // Sektion 3: Trending (hier: zufällige Auswahl)
                    let trendingAll = allBooks.shuffled()
                    let trendingVisible = Array(trendingAll.prefix(8))
                    DiscoverSectionHeader(
                        titleKey: "discover.section.trending",
                        showSeeAll: trendingAll.count > 8,
                        seeAllDestination: AnyView(
                            DiscoverAllView(searchText: searchText, category: .popular)
                        )
                    )
                    horizontalBooks(trendingVisible)
                }
                .padding(.vertical, AppSpace._16)
            }
        }
        .background(AppColors.Semantic.bgPrimary)
        .navigationTitle(Text(LocalizedStringKey("rr.tab.discover")))
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("discover.view")
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack(spacing: AppSpace._8) {
            Image(systemName: "magnifyingglass")
            TextField(text: $searchText) {
                Text(LocalizedStringKey("discover.search.placeholder"))
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            Spacer()
            Image(systemName: "slider.horizontal.3")
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
                ForEach(Array(categories.enumerated()), id: \.offset) { _, key in
                    Button {
                        // toggle selection
                        if let current = selectedCategory, key == catTitle(current) {
                            selectedCategory = nil
                        } else {
                            // map LocalizedStringKey back to enum by index
                            if let idx = categories.firstIndex(of: key), idx < Category.allCases.count {
                                selectedCategory = Category.allCases[idx]
                            }
                        }
                    } label: {
                        let isActive: Bool = {
                            if let current = selectedCategory, let idx = categories.firstIndex(of: key) {
                                return Category.allCases[idx] == current
                            }
                            return false
                        }()
                        Text(key)
                            .font(.footnote)
                            .padding(.horizontal, AppSpace._12)
                            .padding(.vertical, AppSpace._8)
                            .background(Capsule().fill(AppColors.Semantic.bgElevated))
                            .overlay(
                                Capsule().stroke(isActive ? AppColors.brandPrimary : AppColors.Semantic.borderMuted, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, AppSpace._16)
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("discover.chips")
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
