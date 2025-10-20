//
//  InsightsView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @ObservedObject private var vm: ProfileViewModel

    init(context: ModelContext) {
        self.vm = ProfileViewModel(context: context)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {
                Text(String(localized: "insights.title"))
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                sectionWeekdayMinutes()

                // Platzhalter für weitere Panels (Charts später)
                // sectionReadingVsListening()
            }
            .padding(.horizontal, AppSpace.lg)
            .padding(.top, AppSpace.lg)
        }
        .navigationTitle(Text(String(localized: "insights.nav.title")))
        .onAppear { vm.reload() }
    }

    private func sectionWeekdayMinutes() -> some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text(String(localized: "insights.section.weekday"))
                .font(.headline)
            Text(String(localized: "insights.section.weekday.subtitle"))
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            // Statt Chart: einfache Liste (Phase: Erstellung, kein Polish)
            VStack(spacing: 8) {
                let cal = Calendar.current
                let _ = cal.dateInterval(of: .month, for: .now)!
                // Recompute local so we don't expose service here; ProfileVM hält Logik
                // In Iteration 2 ziehen wir echte Charts aus vm (Datenstruktur erweitern).
                ForEach(0..<7, id: \.self) { i in
                    HStack {
                        Text(vm.weekdayLabel(for: i))
                        Spacer()
                        // Heuristik: Wir haben bestWeekday nur als max; hier Dummy 0.
                        // In Iteration 2 liefert VM ein vollständiges Array.
                        Text(i == vm.bestWeekdayIndex ? "\(vm.bestWeekdayMinutes)" : "0")
                            .monospacedDigit()
                            .foregroundColor(i == vm.bestWeekdayIndex ? AppColors.brandPrimary : AppColors.textPrimary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .padding()
            .background(AppColors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.l)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
            )
        }
        .accessibilityIdentifier("Insights.WeekdayMinutes")
    }
}
