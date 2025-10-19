//
//  BookRowView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//


//
//  BookRowView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI
import SwiftData

/// Kompakte Zeile für die Library-Liste.
/// Zeigt kleines Cover (Initialen-Placeholder), Titel & Autor.
/// Bild-Handling kann später einfach ergänzt werden.
struct BookRowView: View {
    let book: BookEntity

    // MARK: - Derived
    private var authorText: String {
        (book.author?.isEmpty == false) ? book.author! : String(localized: "book.unknownAuthor")
    }

    private var initials: String {
        let words = book.title
            .split(separator: " ")
            .prefix(2)
            .map { $0.prefix(1).uppercased() }
            .joined()
        return words.isEmpty ? "BK" : words
    }

    var body: some View {
        HStack(spacing: 12) {
            CoverThumbnail(initials: initials)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(authorText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .accessibilityIdentifier("library.row.author.\(book.persistentModelID.hashValue)")
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("library.row.\(book.persistentModelID.hashValue)")
    }
}

// MARK: - Subviews

/// Kleiner, neutraler Cover-Placeholder.
/// Später durch echtes `AsyncImage` / Asset ersetzbar.
private struct CoverThumbnail: View {
    let initials: String

    var body: some View {
        ZStack {
            // Hintergrund/Card – bitte später an das App-Design-System anbinden
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color(uiColor: .separator), lineWidth: 0.5)

            Text(initials)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(width: 44, height: 60)
    }
}

