//
//  DiscoverDetailView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI
import SwiftData

struct DiscoverDetailView: View {
    @ObservedObject private var vm: DiscoverDetailViewModel
    @Environment(\.modelContext) private var context

    init(book: BookEntity) {
        self.vm = DiscoverDetailViewModel(book: book)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {
                headerCover()
                metaSection()
                summarySection()
                primaryCTA()
            }
            .padding(.horizontal, AppSpace.lg)
            .padding(.top, AppSpace.xl)
        }
        .navigationTitle(Text(LocalizedStringKey("discover.detail.title")))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    @ViewBuilder
    private func headerCover() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                .fill(AppColors.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.l)
                        .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                )
                .frame(height: 220)

            // Platzhalter-Cover (kannst du später mit echtem Cover ersetzen)
            Image(systemName: "book.closed.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.brandPrimary)
                .accessibilityHidden(true)
        }
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
        .accessibilityIdentifier("DiscoverDetail.Cover")
    }

    private func metaSection() -> some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text(vm.title)
                .font(.title2.weight(.semibold))
                .foregroundColor(AppColors.textPrimary)
                .accessibilityIdentifier("DiscoverDetail.Title")

            if let author = vm.author, !author.isEmpty {
                Text(author)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .accessibilityIdentifier("DiscoverDetail.Author")
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func summarySection() -> some View {
        if let summary = vm.summary, !summary.isEmpty {
            VStack(alignment: .leading, spacing: AppSpace.sm) {
                Text(LocalizedStringKey("discover.detail.about"))
                    .font(.headline)
                Text(summary)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(AppColors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.l)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
            )
            .accessibilityIdentifier("DiscoverDetail.Summary")
        }
    }

    private func primaryCTA() -> some View {
        NavigationLink {
            BookDetailView(book: vm.book) // bereits in deinem Projekt vorhanden
        } label: {
            Text(LocalizedStringKey("discover.detail.cta.open"))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("DiscoverDetail.CTA.Open")
    }
}

#if DEBUG
struct DiscoverDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Minimaler Preview: Du kannst hier deine Seed-Daten nutzen
        Text("DiscoverDetailView Preview – bitte mit echter BookEntity in Laufzeit testen.")
            .padding()
    }
}
#endif
