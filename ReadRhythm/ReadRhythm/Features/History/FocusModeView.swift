//
//  FocusModeView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI
import SwiftData

struct FocusModeView: View {
    @StateObject private var vm: FocusModeViewModel

    init(context: ModelContext) {
        _vm = StateObject(wrappedValue: FocusModeViewModel(context: context))
    }

    var body: some View {
        VStack(spacing: AppSpace.xl) {
            // Header
            VStack(spacing: AppSpace.xs) {
                Text(LocalizedStringKey("focus.title"))
                    .font(.title2).bold()
                Text(LocalizedStringKey("focus.subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.top, AppSpace.xl)

            // Timer Display
            Text(vm.formattedRemaining())
                .font(.system(size: 56, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: AppRadius.xl).stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75))
                .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
                .accessibilityIdentifier("Focus.Timer")

            // Duration Slider
            VStack(alignment: .leading, spacing: AppSpace.sm) {
                Text(LocalizedStringKey("focus.duration"))
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                Slider(value: Binding(
                    get: { Double(vm.durationMinutes) },
                    set: { vm.updateDuration(Int($0)) }
                ), in: 5...120, step: 5)
                Text("\(vm.durationMinutes) " + String(localized: "goals.metric.minutes"))
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpace.lg)

            // Controls
            HStack(spacing: AppSpace.md) {
                Button {
                    vm.start()
                } label: {
                    Label(LocalizedStringKey("focus.action.start"), systemImage: "play.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isRunning)
                .accessibilityIdentifier("Focus.Start")

                Button {
                    vm.pause()
                } label: {
                    Label(LocalizedStringKey("focus.action.pause"), systemImage: "pause.circle")
                }
                .buttonStyle(.bordered)
                .disabled(!vm.isRunning)
                .accessibilityIdentifier("Focus.Pause")

                Button(role: .destructive) {
                    vm.stop()
                } label: {
                    Label(LocalizedStringKey("focus.action.stop"), systemImage: "stop.circle")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("Focus.Stop")
            }

            Spacer()
        }
        .padding(.horizontal, AppSpace.lg)
        .navigationTitle(Text(LocalizedStringKey("focus.nav.title")))
    }
}
