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
                let displayData = vm.displaySections()
                ForEach(displayData, id: \.date) { section in
                    sectionView(section.date, rows: section.rows)
                }

                if displayData.isEmpty {
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

    private func sectionView(_ day: Date, rows: [HistoryRowDisplayData]) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.md) {
            Text(vm.dayLabel(day))
                .font(.headline)
                .padding(.horizontal, AppSpace.xs)

            VStack(spacing: 8) {
                ForEach(rows) { row in
                    rowView(for: row)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func rowView(for row: HistoryRowDisplayData) -> some View {
        HStack(spacing: AppSpace.md) {
            Image(systemName: row.iconSystemName)
                .foregroundStyle(row.iconSystemName == "headphones" ? AppColors.brandSecondary : AppColors.brandPrimary)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(row.subtitleText)
                    .font(.subheadline)
                    .accessibilityIdentifier("History.Row.Title.\(row.id.uuidString.prefix(6))")

                Text("\(row.timeText) · \(row.titleText)")
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
        .accessibilityIdentifier("History.Row.\(row.id.uuidString.prefix(6))")
    }

}
