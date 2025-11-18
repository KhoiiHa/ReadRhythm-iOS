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
    @State private var isPressed = false

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
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.Semantic.bgCard.opacity(0.96),
                            AppColors.Semantic.bgCard.opacity(1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: AppColors.Semantic.shadow.opacity(0.12),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.easeOut(duration: 0.15), value: isPressed)
            HStack(spacing: 12) {
                // <-- kleines Cover
                LibraryRowCoverArtwork(
                    thumbnailURL: thumbnailURL,
                    initials: initials
                )
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(AppFont.headingM())
                        .foregroundStyle(AppColors.Semantic.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .accessibilityIdentifier("library.row.title.\(book.persistentModelID.hashValue)")

                    Text(authorText)
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .opacity(0.8)
                        .lineLimit(1)
                        .padding(.top, 1)
                        .accessibilityIdentifier("library.row.author.\(book.persistentModelID.hashValue)")

                    // Badge für echte API-Importe (Google Books)
                    if isRemoteImported {
                        Text("Google Books")
                            .font(AppFont.caption2())
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppColors.Brand.primary.opacity(0.08))
                            )
                            .foregroundStyle(AppColors.Brand.primary)
                            .padding(.top, 4)
                            .accessibilityIdentifier("library.row.badge.google.\(book.persistentModelID.hashValue)")
                    }
                }

                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
        }
        .contentShape(RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous))
        .hoverEffect(.highlight)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isPressed = false
            }
        }
        .accessibilityLabel(Text("\(book.title), \(authorText)"))
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
                .fill(AppColors.Semantic.bgCard)

            RoundedRectangle(cornerRadius: AppRadius.s, style: .continuous)
                .strokeBorder(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)

            Text(initials)
                .font(AppFont.headingS())
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
                            .fill(AppColors.Semantic.bgCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.s, style: .continuous)
                                    .strokeBorder(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)
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
                                    .strokeBorder(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)
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
