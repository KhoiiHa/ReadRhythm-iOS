//
//  ReadingHistoryView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI
import SwiftData

@MainActor
struct ReadingHistoryView: View {
    @StateObject private var vm: ReadingHistoryViewModel

    init(context: ModelContext) {
        _vm = StateObject(wrappedValue: ReadingHistoryViewModel(context: context))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpace.lg, pinnedViews: []) {
                ForEach(vm.sections, id: \.date) { section in
                    sectionView(section.date, items: section.items)
                }

                if vm.sections.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, AppSpace.lg)
            .padding(.top, AppSpace.lg)
        }
        .navigationTitle(Text(LocalizedStringKey("history.title")))
        .task {
            vm.reload()
        }
        .accessibilityIdentifier("History.Root")
    }

    private var emptyState: some View {
        VStack(spacing: AppSpace.sm) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.textSecondary)
            Text(LocalizedStringKey("history.empty.title"))
                .font(.headline)
            Text(LocalizedStringKey("history.empty.subtitle"))
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 240)
        .accessibilityIdentifier("History.Empty")
    }

    private func sectionView(_ day: Date, items: [ReadingHistoryItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.md) {
            Text(vm.dayLabel(day))
                .font(.headline)
                .padding(.horizontal, AppSpace.xs)

            VStack(spacing: 8) {
                ForEach(items) { item in
                    rowView(for: item)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func rowView(for item: ReadingHistoryItem) -> some View {
        HStack(spacing: AppSpace.md) {
            // Icon abhängig vom Medium: Lesen 📖 oder Hören 🎧
            Image(systemName: item.medium == "listening" ? "headphones" : "book.closed.fill")
                .foregroundStyle(item.medium == "listening" ? AppColors.brandSecondary : AppColors.brandPrimary)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.bookTitle)
                    .font(.subheadline)
                    .accessibilityIdentifier("History.Row.Title.\(item.id.uuidString.prefix(6))")

                Text("\(vm.timeLabel(item.date)) · \(item.minutes) " + String(localized: "goals.metric.minutes"))
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, AppSpace.md)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.l)
                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
        )
        .shadow(color: AppShadow.card.color,
                radius: AppShadow.card.radius,
                x: AppShadow.card.x,
                y: AppShadow.card.y)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(historyAccessibilityLabel(for: item))
        .accessibilityIdentifier("History.Row.\(item.id.uuidString.prefix(6))")
    }

    private func historyAccessibilityLabel(for item: ReadingHistoryItem) -> String {
        let mediumText = (item.medium == "listening")
            ? String(localized: "history.medium.listening")
            : String(localized: "history.medium.reading")

        let dayText = vm.dayLabel(item.date)

        return "\(item.minutes) Minuten \(mediumText) am \(dayText)"
    }
}
