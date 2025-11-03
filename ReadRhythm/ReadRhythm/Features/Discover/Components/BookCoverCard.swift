//
//  BookCoverCard.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI

struct BookCoverCard: View {
    let title: String
    let author: String?
    let coverURL: URL?
    let coverAssetName: String?

    /// Wird aufgerufen, wenn der Nutzer auf "+" tippt.
    var onAddToLibrary: (() -> Void)?

    private let coverSize = CGSize(width: 120, height: 180)

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace._8) {
            ZStack(alignment: .topTrailing) {
                // Cover Image or Placeholder
                if let coverAssetName = coverAssetName {
                    Image(coverAssetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: coverSize.width, height: coverSize.height)
                        .clipped()
                        .cornerRadius(AppRadius.l)
                        .shadow(color: AppColors.Semantic.shadowColor, radius: 4, x: 0, y: 2)
                        .accessibilityHidden(true)
                } else if let coverURL = coverURL {
                    AsyncImage(url: coverURL) { phase in
                        switch phase {
                        case .empty:
                            placeholderCover
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: coverSize.width, height: coverSize.height)
                                .clipped()
                                .cornerRadius(AppRadius.l)
                                .shadow(color: AppColors.Semantic.shadowColor, radius: 4, x: 0, y: 2)
                                .accessibilityHidden(true)
                        case .failure:
                            placeholderCover
                        @unknown default:
                            placeholderCover
                        }
                    }
                } else {
                    placeholderCover
                }

                // Add-to-Library Button
                if let onAddToLibrary = onAddToLibrary {
                    Button(action: {
                        onAddToLibrary()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AppColors.Semantic.tintPrimary)
                            .shadow(radius: 2)
                    }
                    .padding(6)
                    .accessibilityLabel(Text("book.addToLibrary"))
                    .accessibilityIdentifier("bookcard.addButton")
                }
            }

            // Texte
            Text(title)
                .font(AppFont.bodyStandard(.semibold))
                .lineLimit(2)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityIdentifier("bookcard.title")

            Text(author ?? String(localized: "book.unknownAuthor"))
                .font(AppFont.caption())
                .lineLimit(1)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .accessibilityIdentifier("bookcard.author")
        }
        .frame(width: coverSize.width)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("discover.card.book"))
    }

    private var placeholderCover: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                .fill(AppColors.Semantic.bgCard)
                .shadow(color: AppColors.Semantic.shadowColor, radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.l)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.Semantic.tintPrimary.opacity(0.6), AppColors.Semantic.tintSecondary.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )

            Text(initials(from: title))
                .font(.largeTitle).bold()
                .foregroundStyle(AppColors.Semantic.tintPrimary.opacity(0.8))
        }
        .frame(width: coverSize.width, height: coverSize.height)
    }

    private func initials(from text: String) -> String {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let initials = words.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}
