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

    // Breiteres Verhältnis für Behance-Style-Cards 
    private let coverSize = CGSize(width: 140, height: 190)

    private var coverView: some View {
        Group {
            if let coverAssetName = coverAssetName {
                Image(coverAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: coverSize.width, height: coverSize.height)
                    .clipped()
                    .cornerRadius(AppRadius.l)
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
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppSpace._4) {
            Text(title)
                .font(AppFont.bodyStandard(.semibold))
                .lineLimit(2)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityIdentifier("bookcard.title")

            if let onAddToLibrary = onAddToLibrary {
                HStack(alignment: .firstTextBaseline, spacing: AppSpace._4) {
                    Text(author ?? String(localized: "book.unknownAuthor"))
                        .font(AppFont.caption2())
                        .lineLimit(1)
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .accessibilityIdentifier("bookcard.author")

                    Spacer(minLength: AppSpace._4)

                    Button(action: {
                        onAddToLibrary()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(AppColors.Semantic.tintPrimary)
                            )
                            .foregroundStyle(AppColors.Semantic.bgCard)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("book.addToLibrary"))
                    .accessibilityIdentifier("bookcard.addButton")
                }
            } else {
                Text(author ?? String(localized: "book.unknownAuthor"))
                    .font(AppFont.caption2())
                    .lineLimit(1)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .accessibilityIdentifier("bookcard.author")
            }
        }
        .padding(AppSpace._8)
    }

    var body: some View {
        VStack(spacing: 0) {
            coverView
            infoSection
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.l)
                .fill(AppColors.Semantic.bgCard)
                .shadow(
                    color: AppColors.Semantic.shadowColor.opacity(0.22),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .frame(width: coverSize.width)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("discover.card.book"))
    }

    private var placeholderCover: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                .fill(AppColors.Semantic.bgCard)
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
                .font(AppFont.headingL())
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
