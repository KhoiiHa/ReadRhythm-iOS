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
                .font(.headline)
            Spacer()
            Button("Fertig") {
                isPresented = false
            }
            .font(.headline)
        }
    }

    /// Zeigt die aktuell ausgewählte Kategorie als Card
    private var activeCategorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Aktive Kategorie")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                if let cat = viewModel.selectedCategory {
                    Image(systemName: cat.systemImage)
                    Text(cat.displayName)
                } else {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text("Keine Kategorie")
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemGray6))
            )
        }
    }

    /// Grid mit allen Kategorien – tap zum Auswählen / Deselektieren
    private var categoriesGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kategorien")
                .font(.subheadline)
                .foregroundColor(.secondary)

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
                            Text(cat.displayName)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(isActive ? .white : .primary)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isActive ? Color(red: 0.56, green: 0.16, blue: 0.16) // rot angelehnt
                                               : Color(.systemGray6))
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
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(red: 0.73, green: 0.36, blue: 0.36)) // behance-rot-ish
            )
            .foregroundColor(.white)
        }
        .padding(.horizontal, 4)
    }
}
