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


/// Vollansicht für Discover – zeigt alle Bücher mit Such- und Chip-Filter.
/// Kontext: Wird aus DiscoverView via "Alle anzeigen" geöffnet und übernimmt den aktuellen Filterzustand.
struct DiscoverAllView: View {
    // Eingehender Filter-Zustand aus Discover
    let initialSearchText: String
    let initialCategory: DiscoverCategory?

    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\BookEntity.createdAt, order: .reverse)])
    private var allBooks: [BookEntity]

    // ViewModel für Remote-Suche (API + Offline-Fallback)
    @StateObject private var viewModel = DiscoverViewModel()

    private enum SortOption: String, CaseIterable, Identifiable { case title, author, date; var id: String { rawValue } }
    @State private var sortOption: SortOption = .title

    init(searchText: String, category: DiscoverCategory?) {
        self.initialSearchText = searchText
        self.initialCategory = category
    }
    
    private var navTitleKey: LocalizedStringKey {
        if let cat = viewModel.selectedCategory {
            // Verwende den i18n-Key der Kategorie (rawValue), nicht den bereits lokalisierten displayName
            return LocalizedStringKey(cat.rawValue)
        } else {
            return LocalizedStringKey("discover.all.title")
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace._16) {
                searchBar
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
                    resultsGrid(viewModel.results)
                        .padding(.horizontal, AppSpace._16)
                } else {
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
                                    viewModel.searchQuery = ""
                                    viewModel.applyFilter(category: nil)
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
        .overlay(alignment: .bottom) {
            if let key = viewModel.toastMessageKey {
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
                    .animation(.easeInOut(duration: 0.2), value: viewModel.toastMessageKey)
                    .accessibilityIdentifier("toast.\(key)")
            }
        }
        .onAppear {
            // Lokale Library laden (für Fallback)
            viewModel.loadBooks(from: context)
            // Eingehende Filter anwenden
            viewModel.searchQuery = initialSearchText
            viewModel.applyFilter(category: initialCategory)
            // Falls ein manueller Suchstring vorhanden ist, Suche starten
            if !initialSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.applySearch()
            }
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack(spacing: AppSpace._8) {
            Image(systemName: "magnifyingglass")
            TextField(text: $viewModel.searchQuery) {
                Text(LocalizedStringKey("discover.search.placeholder"))
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onSubmit { viewModel.applySearch() }
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
                ForEach(DiscoverCategory.ordered, id: \.id) { cat in
                    let isActive = (viewModel.selectedCategory == cat)
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
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
                        .background(Capsule().fill(AppColors.Semantic.bgElevated))
                        .overlay(
                            Capsule().stroke(isActive ? AppColors.brandPrimary : AppColors.Semantic.borderMuted, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("discover.all.chip.\(cat.id)")
                }
            }
            .padding(.horizontal, AppSpace._16)
        }
    }

    /// Zeigt Remote-Ergebnisse (Google Books) in einem adaptiven Grid.
    private func resultsGrid(_ items: [RemoteBook]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: AppSpace._12)], spacing: AppSpace._12) {
            ForEach(items, id: \.id) { book in
                BookCoverCard(title: book.title, author: book.authors, coverURL: book.thumbnailURL, coverAssetName: nil)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("discover.all.result.\(book.id)")
                HStack {
                    Spacer()
                    Button {
                        #if os(iOS)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                        do {
                            try viewModel.addToLibrary(from: book, in: context)
                        } catch {
                            print("⛔️ Add failed: \(error)")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.brandPrimary)
                            .accessibilityLabel(Text(LocalizedStringKey("discover.addToLibrary")))
                            .accessibilityIdentifier("discover.all.addButton.\(book.id)")
                    }
                    .buttonStyle(.plain)
                }
            }
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
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedCategory)
    }

    // MARK: - Lokale Filterlogik (Fallback)
    private var filteredBooks: [BookEntity] {
        let trimmed = viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let base: [BookEntity]
        if trimmed.isEmpty {
            base = allBooks
        } else {
            let q = trimmed.lowercased()
            base = allBooks.filter { b in
                b.title.lowercased().contains(q) || (b.author?.lowercased().contains(q) ?? false)
            }
        }
        guard let cat = viewModel.selectedCategory else { return base }
        switch cat {
        case .fictionRomance:
            return base.filter { $0.title.localizedCaseInsensitiveContains("novel") || $0.title.localizedCaseInsensitiveContains("story") || $0.title.localizedCaseInsensitiveContains("love") }
        case .mindfulness, .philosophy:
            return base.filter { titleIn($0, matchesAnyOf: ["mind", "meditation", "philosophy", "zen"]) }
        case .selfHelp, .psychology:
            return base.filter { titleIn($0, matchesAnyOf: ["habit", "better", "change", "think", "psychology"]) }
        case .creativity, .wellness:
            return base.filter { titleIn($0, matchesAnyOf: ["creative", "art", "design", "health", "wellness"]) }
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
}

#if DEBUG
import SwiftUI

struct DiscoverAllPreviewHarness: View {
    private enum SortOption: String, CaseIterable, Identifiable { case title, author, date; var id: String { rawValue } }
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .title

    var body: some View {
        DiscoverAllView(searchText: searchText, category: nil)
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
