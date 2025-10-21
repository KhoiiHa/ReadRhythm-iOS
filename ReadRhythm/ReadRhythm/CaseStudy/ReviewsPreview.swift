//
//  ReviewsPreview.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 21.10.25.
//

// ReviewsPreview.swift
// ReadRhythm – Case-Study-only (keine App-Abhängigkeiten)
import SwiftUI

#if DEBUG
private struct Review: Identifiable {
    let id = UUID()
    let username: String
    let rating: Int // 1...5
    let isVerified: Bool
    let date: Date
    let comment: String
}

private extension Date {
    static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date())!
    }
}

// MARK: - Star Row
private struct StarRow: View {
    let rating: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .imageScale(.small)
            }
        }
        .foregroundStyle(AppColors.brandPrimary)
        .accessibilityLabel(Text("reviews.stars.a11y.label")) // „Bewertung Sterne“
        .accessibilityValue(Text("\(rating)"))
    }
}

// MARK: - Single Review Card
private struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace._8) {
            HStack(spacing: AppSpace._8) {
                StarRow(rating: review.rating)
                if review.isVerified {
                    Text(LocalizedStringKey("reviews.badge.verified"))
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(AppColors.surfaceSecondary, in: Capsule())
                        .overlay(Capsule().stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75))
                        .accessibilityIdentifier("reviews.badge.verified")
                }
                Spacer()
                Text(review.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text(review.comment)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)

            HStack {
                Text(review.username)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
            }
        }
        .padding(AppSpace._16)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.l).stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75))
        .accessibilityIdentifier("reviews.card.\(review.id.uuidString.prefix(6))")
    }
}

// MARK: - Reviews Section (Case-Study Harness)
private struct ReviewsSectionPreview: View {
    let titleKey: LocalizedStringKey = "reviews.title" // „Rezensionen“
    let reviews: [Review]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace._16) {
                Text(titleKey)
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal, AppSpace._16)
                    .accessibilityIdentifier("reviews.title")

                if reviews.isEmpty {
                    VStack(spacing: AppSpace._8) {
                        Text(LocalizedStringKey("reviews.empty.title"))
                            .font(.headline)
                            .foregroundStyle(AppColors.textSecondary)
                        Text(LocalizedStringKey("reviews.empty.subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpace._16)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpace._8)
                    .accessibilityIdentifier("reviews.empty")
                } else {
                    VStack(spacing: AppSpace._12) {
                        ForEach(reviews) { ReviewCard(review: $0) }
                    }
                    .padding(.horizontal, AppSpace._16)
                }

                Spacer(minLength: AppSpace._16)
            }
            .padding(.top, AppSpace._16)
        }
        .background(AppColors.Semantic.bgPrimary)
        .navigationTitle(Text("reviews.navtitle"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("reviews.section")
    }
}

// MARK: - Previews (Light/Dark, DE)
#Preview("Reviews – 3 Cards (Light, DE)") {
    let sample: [Review] = [
        .init(username: "Mara", rating: 5, isVerified: true,  date: .daysAgo(2), comment: "Wunderbar ruhig. Ich lese täglich 20–30 Minuten – die Ziele motivieren wirklich."),
        .init(username: "Tuan", rating: 4, isVerified: false, date: .daysAgo(7), comment: "Übersichtlich, die Charts sind top. Wünsche mir noch mehr Kategorien."),
        .init(username: "Lena", rating: 5, isVerified: true,  date: .daysAgo(13), comment: "Genau was ich gesucht habe – minimal, schnell, ohne Ablenkung.")
    ]
    return NavigationStack {
        ReviewsSectionPreview(reviews: sample)
            .environment(\.locale, .init(identifier: "de"))
            .preferredColorScheme(.light)
    }
}

#Preview("Reviews – Empty (Dark, DE)") {
    NavigationStack {
        ReviewsSectionPreview(reviews: [])
            .environment(\.locale, .init(identifier: "de"))
            .preferredColorScheme(.dark)
    }
}
#endif
