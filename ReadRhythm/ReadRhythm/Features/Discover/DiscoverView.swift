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

    // einfache Dummy-Kategorien, später aus Service/i18n
    private let categories: [LocalizedStringKey] = [
        "discover.cat.recent", "discover.cat.popular", "discover.cat.fiction", "discover.cat.nonfiction"
    ]

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
                    DiscoverSectionHeader(titleKey: "discover.section.recommended", showSeeAll: true) {}
                    horizontalBooks(Array(allBooks.prefix(8)))

                    // Sektion 2: Aus deiner Library (hier: letzte N Bücher)
                    DiscoverSectionHeader(titleKey: "discover.section.fromLibrary")
                    horizontalBooks(Array(allBooks.suffix(8)))

                    // Sektion 3: Trending (hier: zufällige Auswahl)
                    DiscoverSectionHeader(titleKey: "discover.section.trending")
                    horizontalBooks(Array(allBooks.shuffled().prefix(8)))
                }
                .padding(.vertical, AppSpace._16)
            }
        }
        .background(AppColors.Semantic.bgPrimary)
        .navigationTitle("rr.tab.discover")
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("discover.view")
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack(spacing: AppSpace._8) {
            Image(systemName: "magnifyingglass")
            Text("discover.search.placeholder")
                .foregroundStyle(AppColors.Semantic.textSecondary)
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
                        // TODO: Filter-Logik (später via ViewModel)
                    } label: {
                        Text(key)
                            .font(.footnote)
                            .padding(.horizontal, AppSpace._12)
                            .padding(.vertical, AppSpace._8)
                            .background(Capsule().fill(AppColors.Semantic.bgElevated))
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
                        BookDetailView(book: book)
                    } label: {
                        BookCoverCard(title: book.title, author: book.author, coverURL: nil, coverAssetName: nil)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollTargetLayout()
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
            Text("discover.empty.title")
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
            Text("discover.empty.subtitle")
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
