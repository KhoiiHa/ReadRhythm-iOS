//
//  BookDetailView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import Foundation
import SwiftUI
import SwiftData

/// Kontext → Warum → Wie
/// Kontext: Detailansicht eines gespeicherten Buchs.
/// Warum: Nutzer soll sehen, was er gespeichert hat (Titel, Autor, Quelle, hinzugefügt am, ggf. Cover),
///        ohne dass hierfür Sessions oder Tracking vorausgesetzt wird.
/// Wie: Leichtgewichtiger Screen, keine Abhängigkeit mehr von `book.sessions`
///      (das Feld existiert im aktuellen `BookEntity` nicht mehr).
struct BookDetailView: View {
    let book: BookEntity

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    @State private var readingStats = BookReadingStats()
    @State private var readingContent: ReadingContent? = nil
    @State private var showFullDescription: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace._16) {
                headerSection
                if let content = readingContent {
                    readerSection(content)
                }
                metaSection
            }
            .padding(.horizontal, AppSpace._16)
            .padding(.vertical, AppSpace._16)
        }
        .background(AppColors.Semantic.bgScreen)
        .navigationTitle(Text("book.detail.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityIdentifier("bookdetail.back")
            }
        }
        .onAppear {
            loadReadingStats()
        }
    }

    // MARK: - Header (Hero: Cover + Titel + Autor + Quelle)
    private var headerSection: some View {
        VStack(spacing: AppSpace._16) {
            // Hero-Cover zentriert
            CoverArtwork(
                thumbnailURLString: book.thumbnailURL,
                titleForInitials: book.title,
                width: 140,
                height: 200
            )
            .accessibilityHidden(true)

            // Titel / Untertitel / Autor zentriert unter dem Cover
            VStack(alignment: .center, spacing: AppSpace._6) {
                Text(book.title)
                    .font(AppFont.headingL())
                    .foregroundStyle(AppColors.Semantic.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("bookdetail.title")

                if let subtitle = book.subtitle, subtitle.isEmpty == false {
                    Text(subtitle)
                        .font(AppFont.headingS())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("bookdetail.subtitle")
                }

                Text(authorText)
                    .font(AppFont.bodyStandard())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .accessibilityIdentifier("bookdetail.author")

                if isRemoteImported {
                    Text(LocalizedStringKey("detail.source.google"))
                        .font(AppFont.caption2())
                        .padding(.horizontal, AppSpace._8)
                        .padding(.vertical, AppSpace._4)
                        .background(
                            Capsule()
                                .fill(AppColors.Semantic.chipBg)
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            AppColors.Semantic.chipBg.opacity(0.6),
                                            lineWidth: AppStroke.cardBorder
                                        )
                                )
                        )
                        .foregroundStyle(AppColors.Semantic.chipFg)
                        .accessibilityIdentifier("bookdetail.badge.google")
                        .accessibilityLabel(Text(LocalizedStringKey("detail.source.google")))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(AppSpace._16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.l)
                .fill(AppColors.Semantic.bgCard)
                .shadow(color: AppColors.Semantic.shadowColor.opacity(0.25), radius: 10, x: 0, y: 6)
        )
    }

    // MARK: - Reader
    private func readerSection(_ content: ReadingContent) -> some View {
        NavigationLink {
            ReaderView(
                bookTitle: content.title ?? book.title,
                content: content
            )
        } label: {
            VStack(alignment: .leading, spacing: AppSpace._12) {
                Text(LocalizedStringKey("bookdetail.reader.title"))
                    .font(AppFont.headingS())
                    .foregroundStyle(AppColors.Semantic.textPrimary)
                    .accessibilityHeading(.h2)

                Text(LocalizedStringKey("bookdetail.reader.open"))
                    .font(AppFont.bodyStandard(.semibold))
                    .foregroundStyle(AppColors.Semantic.tintPrimary)
                    .accessibilityIdentifier("bookdetail.reader.open")

                if let progressLabel = readerProgressLabel(for: content) {
                    Text(progressLabel)
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .accessibilityIdentifier("bookdetail.reader.progress")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .cardBackground()
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("bookdetail.reader.card")
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("bookdetail.reader")
    }

    // MARK: - Meta / Zusatzinfos
    private var metaSection: some View {
        VStack(alignment: .leading, spacing: AppSpace._12) {
            Text(LocalizedStringKey("detail.source"))
                .font(AppFont.headingS())
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityHeading(.h2)

            infoRow(icon: "globe", text: Text(LocalizedStringKey(sourceLabelKey)))
                .accessibilityIdentifier("detail.source")

            if let addedText = addedOnText {
                infoRow(icon: "calendar", text: Text(addedText))
                    .accessibilityIdentifier("detail.addedOn")
            }

            if let totalMinutesText = totalMinutesText {
                infoRow(icon: "clock", text: Text(totalMinutesText))
                    .accessibilityIdentifier("detail.totalMinutes")
            }

            if let lastSessionText = lastSessionText {
                infoRow(icon: "clock.arrow.circlepath", text: Text(lastSessionText))
                    .accessibilityIdentifier("detail.lastSession")
            }

            // Rich metadata (if available)
            if let publisher = book.publisher, !publisher.isEmpty {
                infoRow(icon: "building.2", text: Text("\(String(localized: "detail.publisher")): \(publisher)"))
                    .accessibilityIdentifier("detail.publisher")
            }

            if let year = publishedYear {
                infoRow(icon: "calendar", text: Text("\(String(localized: "detail.year")): \(year)"))
                    .accessibilityIdentifier("detail.year")
            }

            if let pages = book.pageCount {
                infoRow(icon: "book", text: Text("\(String(localized: "detail.pages")): \(pages)"))
                    .accessibilityIdentifier("detail.pages")
            }

            if let lang = book.language, !lang.isEmpty {
                infoRow(icon: "globe", text: Text("\(String(localized: "detail.language")): \(lang)"))
                    .accessibilityIdentifier("detail.language")
            }

            if !book.categories.isEmpty {
                VStack(alignment: .leading, spacing: AppSpace._8) {
                    Text(LocalizedStringKey("detail.categories"))
                        .font(AppFont.bodyStandard(.semibold))
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                    Text(book.categories.joined(separator: ", "))
                        .font(AppFont.bodyStandard())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .accessibilityIdentifier("detail.categories.values")
                }
                .accessibilityIdentifier("detail.categories")
            }

            if let desc = book.descriptionText, !desc.isEmpty {
                VStack(alignment: .leading, spacing: AppSpace._8) {
                    Text(LocalizedStringKey("detail.description"))
                        .font(AppFont.headingS())
                        .foregroundStyle(AppColors.Semantic.textPrimary)
                        .accessibilityHeading(.h2)
                    Text(desc)
                        .font(AppFont.bodyStandard())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .lineLimit(showFullDescription ? nil : 3)
                        .accessibilityIdentifier("detail.description.text")
                    Button(showFullDescription ? String(localized: "detail.readLess") : String(localized: "detail.readMore")) {
                        showFullDescription.toggle()
                    }
                    .buttonStyle(.plain)
                    .font(AppFont.caption2(.semibold))
                    .foregroundStyle(AppColors.Semantic.tintPrimary)
                    .accessibilityIdentifier("detail.description.toggle")
                }
                .accessibilityIdentifier("detail.description")
            }

            if let url = googleBooksURL {
                Button {
                    openURL(url)
                } label: {
                    Text(LocalizedStringKey("detail.openInGoogleBooks"))
                        .font(AppFont.caption2(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: AppRadius.s))
                .accessibilityIdentifier("detail.openInGoogleBooks")
            }
        }
        .padding()
        .cardBackground()
        .accessibilityIdentifier("detail.meta")
    }

    // MARK: - Derived helpers

    /// Ob das Buch aus der Google Books API stammt.
    private var isRemoteImported: Bool {
        book.source.lowercased().contains("google")
    }

    /// Lesbare Autorenzeile. Leer? Dann "Unbekannter Autor".
    private var authorText: String {
        book.author.isEmpty
        ? String(localized: "book.unknownAuthor")
        : book.author
    }

    /// Optional formatierter "hinzugefügt am"-Text.
    private var addedOnText: String? {
        let formatted = AppFormatter.shortDateFormatter.string(from: book.dateAdded)
        let template = String(localized: "detail.addedOn")
        return String(format: template, formatted)
    }

    private var totalMinutesText: String? {
        guard readingStats.totalMinutes > 0 else { return nil }
        let template = String(localized: "detail.totalMinutes")
        return String(format: template, readingStats.totalMinutes)
    }

    private var lastSessionText: String? {
        guard let date = readingStats.lastSession else { return nil }
        let formatted = AppFormatter.shortDateFormatter.string(from: date)
        let template = String(localized: "detail.lastSession")
        return String(format: template, formatted)
    }

    private var sourceLabelKey: String {
        isRemoteImported ? "detail.source.google" : "detail.source.manual"
    }

    private var googleBooksURL: URL? {
        // Prefer stored links when available
        if let link = book.infoLink { return link }
        if let preview = book.previewLink { return preview }
        // Fallback to constructing a Google Books URL from the sourceID when the book came from Google
        guard isRemoteImported else { return nil }
        guard let encoded = book.sourceID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://books.google.com/books?id=\(encoded)")
    }

    /// Extracts a year string from ISO-like date strings (YYYY, YYYY-MM, YYYY-MM-DD).
    private var publishedYear: String? {
        guard let raw = book.publishedDate, !raw.isEmpty else { return nil }
        let yearPrefix = raw.prefix(4)
        return yearPrefix.count == 4 ? String(yearPrefix) : nil
    }

    /// Returns a simple reader progress label based on available content.
    private func readerProgressLabel(for content: ReadingContent) -> String? {
        let total = content.pages.count
        guard total > 0 else { return nil }
        // Minimal, non-localized fallback label to avoid missing-keys warnings.
        return "Seiten: \(total)"
    }

    private func infoRow(icon: String, text: Text) -> some View {
        HStack(spacing: AppSpace._8) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.Semantic.textSecondary)
            text
                .font(AppFont.bodyStandard())
                .foregroundStyle(AppColors.Semantic.textSecondary)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    @MainActor
    private func loadReadingStats() {
        let targetID = book.persistentModelID
        let predicate = #Predicate<ReadingSessionEntity> { session in
            session.book?.persistentModelID == targetID
        }
        let descriptor = FetchDescriptor<ReadingSessionEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\ReadingSessionEntity.date, order: .reverse)]
        )

        do {
            let sessions = try modelContext.fetch(descriptor)
            let total = sessions.reduce(0) { $0 + max(0, $1.minutes) }
            let last = sessions.first?.date
            readingStats = BookReadingStats(totalMinutes: total, lastSession: last)
        } catch {
            #if DEBUG
            DebugLogger.log("⚠️ Failed to load reading stats for book detail: \(error.localizedDescription)")
            #endif
            readingStats = BookReadingStats()
        }
    }
}


// MARK: - Supporting types

private struct BookReadingStats {
    var totalMinutes: Int = 0
    var lastSession: Date? = nil
}
