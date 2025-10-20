//
//  DiscoverAllView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

//
//  DiscoverAllView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI
import SwiftData

typealias Category = DiscoverView.Category

/// Vollansicht für Discover – zeigt alle Bücher mit Such- und Chip-Filter.
/// Kontext: Wird aus DiscoverView via "Alle anzeigen" geöffnet und übernimmt den aktuellen Filterzustand.
struct DiscoverAllView: View {
    // Eingehender Filter-Zustand aus Discover
    let initialSearchText: String
    let initialCategory: Category?

    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\BookEntity.createdAt, order: .reverse)])
    private var allBooks: [BookEntity]

    // Lokaler, editierbarer State
    @State private var searchText: String
    @State private var selectedCategory: Category?

    init(searchText: String, category: Category?) {
        self.initialSearchText = searchText
        self.initialCategory = category
        _searchText = State(initialValue: searchText)
        _selectedCategory = State(initialValue: category)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace._16) {
                searchBar
                categoryChips
                grid
                    .padding(.horizontal, AppSpace._16)

                if filteredBooks.isEmpty {
                    Text(LocalizedStringKey("discover.empty.title"))
                        .font(.headline)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.top, AppSpace._16)
                        .accessibilityIdentifier("discover.all.empty")
                }

                Spacer(minLength: AppSpace._16)
            }
            .padding(.top, AppSpace._16)
        }
        .background(AppColors.Semantic.bgPrimary)
        .navigationTitle(Text(LocalizedStringKey("discover.all.title")))
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("discover.all.view")
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
        }
        .font(.subheadline)
        .padding(.horizontal, AppSpace._16)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.m)
                .fill(AppColors.Semantic.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.m)
                        .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, AppSpace._16)
        .accessibilityIdentifier("discover.all.search")
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpace._8) {
                ForEach(Category.allCases, id: \.self) { cat in
                    let isActive = selectedCategory == cat
                    Button {
                        selectedCategory = (isActive ? nil : cat)
                    } label: {
                        Text(catTitle(cat))
                            .font(.footnote)
                            .padding(.horizontal, AppSpace._12)
                            .padding(.vertical, AppSpace._8)
                            .background(Capsule().fill(AppColors.Semantic.bgElevated))
                            .overlay(
                                Capsule().stroke(isActive ? AppColors.brandPrimary : AppColors.Semantic.borderMuted, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("discover.all.chip.\(cat.rawValue)")
                }
            }
            .padding(.horizontal, AppSpace._16)
        }
    }

    private var grid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: AppSpace._12)], spacing: AppSpace._12) {
            ForEach(filteredBooks) { book in
                NavigationLink {
                    DiscoverDetailView(book: book)
                } label: {
                    // Falls dein BookCoverCard den BookEntity-Init hat, kannst du ihn direkt verwenden:
                    // BookCoverCard(book: book)
                    BookCoverCard(title: book.title, author: book.author, coverURL: nil, coverAssetName: nil)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("discover.all.card.\(book.id.uuidString.prefix(6))")
            }
        }
    }

    // MARK: - Filtering (wie in DiscoverView)
    private var filteredBooks: [BookEntity] {
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
        guard let cat = selectedCategory else { return base }
        switch cat {
        case .recent:
            return Array(base.prefix(40))
        case .popular:
            return base.sorted { $0.title < $1.title }
        case .fiction:
            return base.filter { $0.title.localizedCaseInsensitiveContains("novel") || $0.title.localizedCaseInsensitiveContains("story") }
        case .nonfiction:
            return base.filter { titleIn($0, matchesAnyOf: ["guide","clean","design","architecture"]) }
        }
    }

    private func titleIn(_ book: BookEntity, matchesAnyOf parts: [String]) -> Bool {
        parts.contains { p in book.title.range(of: p, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    }

    private func catTitle(_ c: Category) -> LocalizedStringKey {
        switch c {
        case .recent: return LocalizedStringKey("discover.cat.recent")
        case .popular: return LocalizedStringKey("discover.cat.popular")
        case .fiction: return LocalizedStringKey("discover.cat.fiction")
        case .nonfiction: return LocalizedStringKey("discover.cat.nonfiction")
        }
    }
}
