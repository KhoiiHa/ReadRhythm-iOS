//
//  AudiobookLightView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI

struct AudiobookLightView: View {
    @StateObject private var vm: AudiobookLightViewModel

    init(initialText: String = "") {
        _vm = StateObject(wrappedValue: AudiobookLightViewModel(
            initialText: initialText
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {

                // Header
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    Text(LocalizedStringKey("audio.title"))
                        .font(.title2).bold()
                    Text(LocalizedStringKey("audio.subtitle"))
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpace.lg)

                // Text Input
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    Text(LocalizedStringKey("audio.input.label"))
                        .font(.footnote)
                        .foregroundColor(AppColors.textSecondary)

                    TextEditor(text: $vm.text)
                        .frame(minHeight: 160)
                        .padding(8)
                        .background(AppColors.surfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.l)
                                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                        )
                        .accessibilityIdentifier("Audio.TextEditor")
                }
                .padding(.horizontal, AppSpace.lg)

                // Controls
                VStack(spacing: AppSpace.md) {
                    HStack(spacing: AppSpace.md) {
                        Button {
                            vm.play()
                        } label: {
                            Label(LocalizedStringKey("audio.action.play"), systemImage: vm.isPaused ? "play.fill" : "play.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("Audio.Play")

                        Button {
                            vm.pause()
                        } label: {
                            Label(LocalizedStringKey("audio.action.pause"), systemImage: "pause.circle")
                        }
                        .buttonStyle(.bordered)
                        .disabled(!vm.isSpeaking && !vm.isPaused)
                        .accessibilityIdentifier("Audio.Pause")

                        Button(role: .destructive) {
                            vm.stop()
                        } label: {
                            Label(LocalizedStringKey("audio.action.stop"), systemImage: "stop.circle")
                        }
                        .buttonStyle(.bordered)
                        .disabled(!vm.isSpeaking && !vm.isPaused)
                        .accessibilityIdentifier("Audio.Stop")
                    }

                    // Progress
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: vm.progress)
                            .accessibilityIdentifier("Audio.Progress")
                        Text("\(vm.elapsedCharacters)/\(max(vm.totalCharacters,1)) " + NSLocalizedString("audio.progress.chars", comment: "Zeichen"))
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, AppSpace.lg)

                // Sliders
                VStack(spacing: AppSpace.lg) {
                    sliderRow(
                        title: "audio.slider.rate",
                        value: Binding(
                            get: { Double(vm.rate) },
                            set: { vm.updateRate($0) }
                        ),
                        range: 0.35...0.65
                    )

                    sliderRow(
                        title: "audio.slider.pitch",
                        value: Binding(
                            get: { Double(vm.pitch) },
                            set: { vm.updatePitch($0) }
                        ),
                        range: 0.75...1.5
                    )
                }
                .padding(.horizontal, AppSpace.lg)

                Spacer(minLength: AppSpace.xl)
            }
            .padding(.top, AppSpace.lg)
        }
        .navigationTitle(Text(LocalizedStringKey("audio.nav.title")))
    }

    // MARK: - Subviews
    private func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text(LocalizedStringKey(title))
                .font(.footnote)
                .foregroundColor(AppColors.textSecondary)
            Slider(value: value, in: range)
                .accessibilityIdentifier("Audio.\(title).Slider")
        }
        .frame(maxWidth: .infinity)
    }
}

