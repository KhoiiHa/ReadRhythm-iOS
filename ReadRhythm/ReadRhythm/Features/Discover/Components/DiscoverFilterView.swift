//
//  DiscoverFilterView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 06.11.25.
//

import SwiftUI

struct DiscoverFilterView: View {
    /// ViewModel aus der DiscoverView
    @ObservedObject var viewModel: DiscoverViewModel

    /// Alle verfügbaren Kategorien (kommt aus DiscoverView)
    let allCategories: [DiscoverCategory]

    /// Sheet-Steuerung (wird von DiscoverView übergeben)
    @Binding var isPresented: Bool

    // 3-spaltiges Grid wie im Behance-Layout
    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 3
    )

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            header

            activeCategorySection

            categoriesGridSection

            Spacer(minLength: 0)

            resetButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Teil-Views

    private var header: some View {
        HStack {
            Text("Filter")
                .font(AppFont.headingS())
                .foregroundStyle(AppColors.Semantic.textPrimary)

            Spacer()

            Button {
                isPresented = false
            } label: {
                Text("Fertig")
                    .font(AppFont.bodyStandard().weight(.semibold))
            }
            .buttonStyle(.borderless)
            .tint(AppColors.Semantic.tintPrimary)
        }
    }

    /// Zeigt die aktuell ausgewählte Kategorie als Card
    private var activeCategorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Aktive Kategorie")
                .font(AppFont.caption1())
                .foregroundStyle(AppColors.Semantic.textSecondary)

            HStack(spacing: 8) {
                if let cat = viewModel.selectedCategory {
                    Image(systemName: cat.systemImage)
                        .foregroundStyle(AppColors.Semantic.tintPrimary)
                    Text(cat.displayName)
                        .font(AppFont.bodyStandard())
                        .foregroundStyle(AppColors.Semantic.textPrimary)
                } else {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                    Text("Keine Kategorie")
                        .font(AppFont.bodyStandard())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.Semantic.bgCard)
            )
        }
    }

    /// Grid mit allen Kategorien – tap zum Auswählen / Deselektieren
    private var categoriesGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kategorien")
                .font(AppFont.caption1())
                .foregroundStyle(AppColors.Semantic.textSecondary)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(allCategories) { cat in
                    let isActive = (viewModel.selectedCategory == cat)

                    Button {
                        // Toggle-Logik: gleiche Kategorie -> entfernen, sonst setzen
                        let newSelection: DiscoverCategory? = isActive ? nil : cat
                        viewModel.applyFilter(category: newSelection)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.systemImage)
                                .foregroundStyle(
                                    isActive
                                    ? AppColors.Semantic.bgScreen
                                    : AppColors.Semantic.textPrimary
                                )
                            Text(cat.displayName)
                                .font(AppFont.caption2())
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    isActive
                                    ? AppColors.Semantic.tintPrimary
                                    : AppColors.Semantic.bgCard
                                )
                        )
                    }
                }
            }
        }
    }

    /// Unterer „Filter zurücksetzen“-Button
    private var resetButton: some View {
        Button {
            viewModel.applyFilter(category: nil)
        } label: {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                Text("Filter zurücksetzen")
            }
            .font(AppFont.bodyStandard().weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppColors.Semantic.tintPrimary)
            )
            .foregroundStyle(AppColors.Semantic.bgScreen)
        }
        .padding(.horizontal, 4)
    }
}
