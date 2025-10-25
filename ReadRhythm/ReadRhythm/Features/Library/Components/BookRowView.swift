//
//  BookRowView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI
import SwiftData

/// Kompakte Zeile für die Library-Liste.
/// Zeigt kleines Cover (Initialen-Placeholder oder echtes Thumbnail),
/// dazu Titel & Autor.
struct BookRowView: View {
    let book: BookEntity

    // MARK: - Derived

    private var authorText: String {
        // author ist jetzt ein non-optional String in BookEntity.
        // Falls leer -> "Unbekannter Autor"
        book.author.isEmpty
        ? String(localized: "book.unknownAuthor")
        : book.author
    }

    /// Zwei Buchstaben aus dem Titel (Fallback fürs Placeholder-Cover)
    private var initials: String {
        let words = book.title
            .split(separator: " ")
            .prefix(2)
            .map { $0.prefix(1).uppercased() }
            .joined()
        return words.isEmpty ? "BK" : words
    }

    /// Buch stammt aus der Google Books API, erkennbar an source == "Google Books"
    private var isRemoteImported: Bool {
        book.source == "Google Books"
    }

    /// Optionale fertige URL zum Cover (vom API-Mapping)
    private var thumbnailURL: URL? {
        if let raw = book.thumbnailURL,
           let url = URL(string: raw) {
            return url
        }
        return nil
    }

    var body: some View {
        HStack(spacing: 12) {
            // <-- kleines Cover
            LibraryRowCoverArtwork(
                thumbnailURL: thumbnailURL,
                initials: initials
            )
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .accessibilityIdentifier("library.row.title.\(book.persistentModelID.hashValue)")

                Text(authorText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .accessibilityIdentifier("library.row.author.\(book.persistentModelID.hashValue)")

                // Badge für echte API-Importe (Google Books)
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
                                        .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.5)
                                )
                        )
                        .accessibilityIdentifier("library.row.badge.google.\(book.persistentModelID.hashValue)")
                }
            }

            Spacer()
        }
        .accessibilityLabel(Text("\(book.title), \(authorText)"))
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.s, style: .continuous)
                .fill(
                    isRemoteImported
                    ? AppColors.Semantic.bgElevated.opacity(0.3)
                    : .clear
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("library.row.\(book.persistentModelID.hashValue)")
    }
}

// MARK: - Internal helper views just for the row

/// Placeholder-Kachel mit Initialen (wenn kein Cover verfügbar)
private struct LibraryRowCoverPlaceholder: View {
    let initials: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.s, style: .continuous)
                .fill(AppColors.Semantic.bgElevated)

            RoundedRectangle(cornerRadius: AppRadius.s, style: .continuous)
                .strokeBorder(AppColors.Semantic.borderMuted, lineWidth: 0.5)

            Text(initials)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.Semantic.textSecondary)
        }
    }
}

/// Kleines Cover für die Library-Zeile:
/// - Falls thumbnailURL vorhanden → AsyncImage-Cover.
/// - Sonst Initialen-Placeholder.
///
/// Wichtig: eigener eindeutiger Name (`LibraryRowCoverArtwork`)
/// damit wir nicht mit `CoverArtwork` aus anderen Screens kollidieren.
private struct LibraryRowCoverArtwork: View {
    let thumbnailURL: URL?
    let initials: String

    // feste Größe für die Liste
    private let width: CGFloat = 44
    private let height: CGFloat = 60

    var body: some View {
        Group {
            if let url = thumbnailURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: AppRadius.s, style: .continuous)
                            .fill(AppColors.Semantic.bgElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.s, style: .continuous)
                                    .strokeBorder(AppColors.Semantic.borderMuted, lineWidth: 0.5)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(
                                RoundedRectangle(cornerRadius: AppRadius.s, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.s, style: .continuous)
                                    .strokeBorder(AppColors.Semantic.borderMuted, lineWidth: 0.5)
                            )
                    case .failure:
                        LibraryRowCoverPlaceholder(initials: initials)
                    @unknown default:
                        LibraryRowCoverPlaceholder(initials: initials)
                    }
                }
            } else {
                LibraryRowCoverPlaceholder(initials: initials)
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }
}
