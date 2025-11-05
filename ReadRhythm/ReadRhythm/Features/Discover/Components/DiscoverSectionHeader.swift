//
//  DiscoverSectionHeader.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI

/// Kontext → Warum → Wie
/// - Kontext: Abschnittsüberschrift für Discover-Sektionen (z. B. Empfohlen, Trending).
/// - Warum: Konsistente Hierarchie & wiederverwendbarer Header mit optionaler „See All“-Navigation.
/// - Wie: Schlanke View mit i18n-Keys, Theme-Farben und stabilen A11y-IDs.
struct DiscoverSectionHeader: View {
    let titleKey: LocalizedStringKey
    var showSeeAll: Bool = false
    var onSeeAll: (() -> Void)? = nil
    var seeAllDestination: AnyView? = nil // Optional: NavigationLink-Ziel

    /// Convenience-Init mit String-Key (kompatibel zu bestehendem Aufruf)
    init(titleKey: String,
         showSeeAll: Bool = false,
         onSeeAll: (() -> Void)? = nil,
         seeAllDestination: AnyView? = nil) {
        self.titleKey = LocalizedStringKey(titleKey)
        self.showSeeAll = showSeeAll
        self.onSeeAll = onSeeAll
        self.seeAllDestination = seeAllDestination
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(titleKey)
                .font(AppFont.headingM())
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .tracking(0.3)
                .accessibilityIdentifier("discover.section.header.title")

            Spacer()

            if let destination = seeAllDestination {
                NavigationLink {
                    destination
                } label: {
                    Text(LocalizedStringKey("discover.seeAll"))
                        .font(AppFont.caption1())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .tracking(0.2)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("discover.section.header.seeall.link")
            } else if showSeeAll {
                Button {
                    onSeeAll?()
                } label: {
                    Text(LocalizedStringKey("discover.seeAll"))
                        .font(AppFont.caption1())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .tracking(0.2)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("discover.section.header.seeall.button")
            }
        }
        .padding(.horizontal, AppSpace._16)
        .padding(.top, AppSpace._12)
        .padding(.bottom, AppSpace._8)
        .background(AppColors.Semantic.bgScreen)
        .accessibilityIdentifier("discover.section.header")
    }
}
