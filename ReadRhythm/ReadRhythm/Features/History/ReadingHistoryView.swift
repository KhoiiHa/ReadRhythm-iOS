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
        .screenBackground()
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
                .foregroundStyle(AppColors.Semantic.textSecondary)
            Text(LocalizedStringKey("history.empty.title"))
                .font(AppFont.headingS())
            Text(LocalizedStringKey("history.empty.subtitle"))
                .font(AppFont.bodyStandard())
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 240)
        .accessibilityIdentifier("History.Empty")
    }

    private func sectionView(_ day: Date, rows: [HistoryRowDisplayData]) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.md) {
            Text(vm.dayLabel(day))
                .font(AppFont.headingS())
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
                    .font(AppFont.bodyStandard())
                    .accessibilityIdentifier("History.Row.Title.\(row.id.uuidString.prefix(6))")

                Text("\(row.timeText) · \(row.titleText)")
                    .font(AppFont.caption2())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, AppSpace.sm)
        .padding(.horizontal, AppSpace.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                .fill(AppColors.Semantic.bgCard)
                .shadow(
                    color: AppColors.Semantic.shadowColor.opacity(0.12),
                    radius: 10,
                    x: 0,
                    y: 6
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
        .accessibilityIdentifier("History.Row.\(row.id.uuidString.prefix(6))")
    }

}
