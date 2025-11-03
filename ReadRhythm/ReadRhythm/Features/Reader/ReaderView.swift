//
//  ReaderView.swift
//  ReadRhythm
//
//  Simple paged reader for demo content.
//

import SwiftUI

struct ReaderView: View {
    let bookTitle: String
    let content: ReadingContent
    let progressRepository: ReadingProgressRepository

    @Environment(\.dismiss) private var dismiss

    @State private var currentPage: Int = 0

    init(
        bookTitle: String,
        content: ReadingContent,
        progressRepository: ReadingProgressRepository = .shared
    ) {
        self.bookTitle = bookTitle
        self.content = content
        self.progressRepository = progressRepository
    }

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(content.pages.enumerated()), id: \.offset) { index, page in
                ScrollView {
                    Text(page)
                        .font(AppFont.bodyStandard())
                        .foregroundStyle(AppColors.Semantic.textPrimary)
                        .padding(.horizontal, AppSpace._16)
                        .padding(.vertical, AppSpace._24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(
                    AppColors.Semantic.bgScreen
                )
                .tag(index)
            }
        }
        .background(
            AppColors.Semantic.bgScreen
        )
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .navigationTitle(Text(bookTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { dismiss() } label: {
                    Text(LocalizedStringKey("reader.close"))
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            pageIndicator
                .padding(.bottom, AppSpace._12)
        }
        .onAppear {
            currentPage = progressRepository.currentPage(
                for: content.bookID,
                totalPages: content.pages.count
            )
        }
        .onChange(of: currentPage) { oldValue, newValue in
            progressRepository.update(
                page: newValue,
                for: content.bookID,
                totalPages: content.pages.count
            )
        }
    }

    private var pageIndicator: some View {
        Text(
            String(
                format: String(localized: "reader.pageIndicator"),
                currentPage + 1,
                content.pages.count
            )
        )
        .font(AppFont.caption())
        .foregroundStyle(AppColors.Semantic.textSecondary)
        .padding(.horizontal, AppSpace._16)
        .padding(.vertical, AppSpace._8)
        .background(
            Capsule(style: .continuous)
                .fill(AppColors.Semantic.bgCard)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)
                )
        )
        .foregroundStyle(AppColors.Semantic.chipFg)
        .accessibilityIdentifier("reader.pageIndicator")
    }
}
