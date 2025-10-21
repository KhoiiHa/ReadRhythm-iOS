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

    private enum SortOption: String, CaseIterable, Identifiable { case title, author, date; var id: String { rawValue } }
    @State private var sortOption: SortOption = .title

    init(searchText: String, category: Category?) {
        self.initialSearchText = searchText
        self.initialCategory = category
        _searchText = State(initialValue: searchText)
        _selectedCategory = State(initialValue: category)
    }
    
    private var navTitleKey: LocalizedStringKey {
        if let cat = selectedCategory {
            switch cat {
            case .recent: return LocalizedStringKey("discover.all.title.recent")
            case .popular: return LocalizedStringKey("discover.all.title.popular")
            case .fiction: return LocalizedStringKey("discover.all.title.fiction")
            case .nonfiction: return LocalizedStringKey("discover.all.title.nonfiction")
            }
        } else {
            return LocalizedStringKey("discover.all.title")
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace._16) {
                searchBar
                categoryChips
                grid
                    .padding(.horizontal, AppSpace._16)

                if displayedBooks.isEmpty {
                    VStack(spacing: AppSpace._12) {
                        Text(LocalizedStringKey("discover.empty.title"))
                            .font(.headline)
                            .foregroundStyle(AppColors.textSecondary)
                        Text(LocalizedStringKey("discover.empty.subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpace._16)
                        Button {
                            #if os(iOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            withAnimation(.easeInOut(duration: 0.25)) {
                                searchText = ""
                                selectedCategory = nil
                            }
                        } label: {
                            Label(LocalizedStringKey("discover.empty.resetFilters"), systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("discover.all.resetFilters")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpace._16)
                }

                Spacer(minLength: AppSpace._16)
            }
            .padding(.top, AppSpace._16)
        }
        .background(AppColors.Semantic.bgPrimary)
        .navigationTitle(Text(navTitleKey))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(LocalizedStringKey("discover.sort.title"), selection: $sortOption) {
                        Text(LocalizedStringKey("discover.sort.byTitle")).tag(SortOption.title)
                        Text(LocalizedStringKey("discover.sort.byAuthor")).tag(SortOption.author)
                        Text(LocalizedStringKey("discover.sort.byDate")).tag(SortOption.date)
                    }
                } label: {
                    Label(LocalizedStringKey("discover.sort.title.short"), systemImage: "arrow.up.arrow.down")
                }
                .accessibilityIdentifier("discover.all.sortMenu")
            }
        }
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
            .accessibilityLabel(Text(LocalizedStringKey("discover.search.placeholder")))
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
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedCategory = (isActive ? nil : cat)
                        }
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
            ForEach(displayedBooks) { book in
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
        .animation(.easeInOut(duration: 0.25), value: selectedCategory)
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

    // Sorted result based on current sort option
    private var displayedBooks: [BookEntity] {
        let base = filteredBooks
        switch sortOption {
        case .title:
            return base.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .author:
            return base.sorted { ($0.author ?? "").localizedCaseInsensitiveCompare($1.author ?? "") == .orderedAscending }
        case .date:
            return base // already reverse-sorted by createdAt via @Query
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

#if DEBUG
import SwiftUI

struct DiscoverAllPreviewHarness: View {
    private enum SortOption: String, CaseIterable, Identifiable { case title, author, date; var id: String { rawValue } }
    @State private var searchText: String = ""
    @State private var selectedCategory: Category? = nil
    @State private var sortOption: SortOption = .title

    var body: some View {
        DiscoverAllView(searchText: searchText, category: selectedCategory)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sortieren", selection: $sortOption) {
                            Text("Titel").tag(SortOption.title)
                            Text("Autor").tag(SortOption.author)
                            Text("Datum").tag(SortOption.date)
                        }
                    } label: {
                        Label("Sortieren", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
    }
}

 #Preview("DiscoverAll – Empty (Light, DE)") {
     let container = try! ModelContainer(for: BookEntity.self)
     NavigationStack {
         DiscoverAllPreviewHarness()
     }
     .modelContainer(container)
     .environment(\.locale, .init(identifier: "de"))
     .preferredColorScheme(.light)
 }

#Preview("DiscoverAll – Empty (Dark, DE)") {
    let container = try! ModelContainer(for: BookEntity.self)
    NavigationStack {
        DiscoverAllPreviewHarness()
    }
    .modelContainer(container)
    .environment(\.locale, .init(identifier: "de"))
    .preferredColorScheme(.dark)
}
#endif
