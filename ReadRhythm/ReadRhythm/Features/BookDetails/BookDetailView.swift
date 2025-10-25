//
//  BookDetailView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace._16) {
                headerSection
                metaSection
            }
            .padding(.horizontal, AppSpace._16)
            .padding(.vertical, AppSpace._16)
        }
        .background(AppColors.Semantic.bgPrimary)
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
    }

    // MARK: - Header (Cover + Titel + Autor + Quelle)
    private var headerSection: some View {
        HStack(alignment: .top, spacing: AppSpace._16) {

            // unified cover component (remote cover or initials fallback)
            CoverArtwork(
                thumbnailURLString: book.thumbnailURL,
                titleForInitials: book.title,
                width: 100,
                height: 140
            )
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpace._8) {
                Text(book.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppColors.Semantic.textPrimary)
                    .multilineTextAlignment(.leading)
                    .accessibilityIdentifier("bookdetail.title")

                Text(authorText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .lineLimit(2)
                    .accessibilityIdentifier("bookdetail.author")

                if isRemoteImported {
                    Text("Google Books")
                        .font(.caption2)
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(AppColors.Semantic.bgElevated)
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            AppColors.Semantic.borderMuted,
                                            lineWidth: 0.5
                                        )
                                )
                        )
                        .accessibilityIdentifier("bookdetail.badge.google")
                }
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Meta / Zusatzinfos
    private var metaSection: some View {
        VStack(alignment: .leading, spacing: AppSpace._12) {
            Text("Details")
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityIdentifier("bookdetail.details.header")

            if let addedText = addedDateText {
                HStack(spacing: AppSpace._8) {
                    Image(systemName: "calendar")
                    Text(addedText)
                }
                .font(.subheadline)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .accessibilityIdentifier("bookdetail.details.added")
            }

            HStack(spacing: AppSpace._8) {
                Image(systemName: "globe")
                Text(sourceText)
            }
            .font(.subheadline)
            .foregroundStyle(AppColors.Semantic.textSecondary)
            .accessibilityIdentifier("bookdetail.details.source")

            if book.thumbnailURL != nil {
                HStack(spacing: AppSpace._8) {
                    Image(systemName: "photo")
                    Text(String(localized: "book.detail.cover.fromWeb"))
                }
                .font(.subheadline)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .accessibilityIdentifier("bookdetail.details.cover")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.m)
                .fill(AppColors.Semantic.bgElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.m)
                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.5)
        )
    }

    // MARK: - Derived helpers

    /// Ob das Buch aus der Google Books API stammt.
    private var isRemoteImported: Bool {
        book.source == "Google Books"
    }

    /// Lesbare Autorenzeile. Leer? Dann "Unbekannter Autor".
    private var authorText: String {
        book.author.isEmpty
        ? String(localized: "book.unknownAuthor")
        : book.author
    }

    /// Optional formatierter "hinzugefügt am"-Text.
    private var addedDateText: String? {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return "Hinzugefügt am \(df.string(from: book.dateAdded))"
    }

    /// Source text or fallback
    private var sourceText: String {
        book.source.isEmpty ? String(localized: "book.unknownSource") : book.source
    }
}
