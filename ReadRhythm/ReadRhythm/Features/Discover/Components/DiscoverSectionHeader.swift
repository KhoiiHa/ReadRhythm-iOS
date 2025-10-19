//
//  DiscoverSectionHeader.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI

/// Kontext → Warum → Wie
/// - Kontext: Abschnittsüberschrift für Discover-Sektionen (z. B. Empfohlen, Trending).
/// - Warum: Konsistente Hierarchie & wiederverwendbarer Header mit optionaler „See All“-Aktion.
/// - Wie: Schlanke View mit i18n-Keys, Theme-Farben und stabilen A11y-IDs.
struct DiscoverSectionHeader: View {
    let titleKey: LocalizedStringKey
    var showSeeAll: Bool = false
    var onSeeAll: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(titleKey)
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityIdentifier("discover.section.header.title")

            Spacer()

            if showSeeAll {
                Button {
                    onSeeAll?()
                } label: {
                    Text("discover.seeAll")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                .tint(AppColors.Semantic.tintPrimary)
                .accessibilityIdentifier("discover.section.header.seeall")
            }
        }
        .padding(.horizontal, AppSpace._16)
        .padding(.top, AppSpace._8)
        .padding(.bottom, AppSpace._4)
        .background(AppColors.Semantic.bgPrimary)
        .accessibilityIdentifier("discover.section.header")
    }
}

