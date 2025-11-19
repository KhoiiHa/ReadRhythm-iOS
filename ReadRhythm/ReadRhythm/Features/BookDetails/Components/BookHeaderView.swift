//
//  BookHeaderView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI

/// Kompakter, wiederverwendbarer Buch-Header.
/// Warum → Wie
/// - Warum: Konsistente Darstellung von Cover + Meta (Titel/Autor) über mehrere Screens hinweg.
/// - Wie: Nutzt BookCoverCard, kapselt Typografie/Spacing, bleibt i18n/A11y- und Theme-freundlich.
struct BookHeaderView: View {
    let title: String
    let author: String?

    var body: some View {
        HStack(alignment: .top, spacing: AppSpace._12) {
            BookCoverCard(
                title: title,
                author: author,
                coverURL: nil,
                coverAssetName: nil,
                isFavorite: false,
                onToggleFavorite: nil
            )
            .frame(width: 120, height: 168)
            .accessibilityIdentifier("book.header.cover")

            VStack(alignment: .leading, spacing: AppSpace._6) {
                Text(title)
                    .font(AppFont.headingL())
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("book.header.title")

                if let author, !author.isEmpty {
                    Text(author)
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .lineLimit(1)
                        .accessibilityIdentifier("book.header.author")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, AppSpace._12)
        .accessibilityElement(children: .combine)
    }
}
