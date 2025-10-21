//
//  FocusModeView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI
import SwiftData
#if os(iOS)
import UIKit
#endif

@MainActor
struct FocusModeView: View {
    @StateObject private var vm: FocusModeViewModel
    @State private var showBookPicker = false
    @State private var hapticsEnabled = true
    @State private var selectedBookTitle: String? = nil

    init(context: ModelContext) {
        _vm = StateObject(wrappedValue: FocusModeViewModel(context: context))
    }

    var body: some View {
        VStack(spacing: AppSpace.xl) {
            // Header
            VStack(spacing: AppSpace.xs) {
                Text(LocalizedStringKey("focus.title"))
                    .font(.title2).bold()
                    .accessibilityIdentifier("Focus.Title")
                Text(LocalizedStringKey("focus.subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.top, AppSpace.xl)

            // Book Picker
            Button {
                showBookPicker = true
            } label: {
                HStack(spacing: AppSpace.sm) {
                    Image(systemName: "book.closed")
                        .imageScale(.medium)
                        .foregroundStyle(AppColors.textSecondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(LocalizedStringKey("focus.picker.title"))
                            .font(.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                        Text(selectedBookTitle ?? String(localized: "focus.picker.choose"))
                            .font(.callout.weight(.semibold))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: AppRadius.l).stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("Focus.BookPicker")
            .sheet(isPresented: $showBookPicker) {
                BookPickerSheet { book in
                    selectedBookTitle = book.title
                    triggerHaptic(.selection)
                }
                .presentationDetents([.medium, .large])
            }

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
                    #if DEBUG
                    print("[Focus] Start pressed, duration=\(vm.durationMinutes)")
                    #endif
                    vm.start()
                    triggerHaptic(.success)
                } label: {
                    Label(LocalizedStringKey("focus.action.start"), systemImage: "play.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isRunning)
                .accessibilityIdentifier("Focus.Start")

                Button {
                    #if DEBUG
                    print("[Focus] Pause pressed")
                    #endif
                    vm.pause()
                    triggerHaptic(.light)
                } label: {
                    Label(LocalizedStringKey("focus.action.pause"), systemImage: "pause.circle")
                }
                .buttonStyle(.bordered)
                .disabled(!vm.isRunning)
                .accessibilityIdentifier("Focus.Pause")

                Button(role: .destructive) {
                    #if DEBUG
                    print("[Focus] Stop pressed")
                    #endif
                    vm.stop()
                    triggerHaptic(.warning)
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
        .accessibilityIdentifier("Focus.Screen")
    }
}

// MARK: - Book Picker Sheet
private struct BookPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \BookEntity.title) private var books: [BookEntity]
    let onSelect: (BookEntity) -> Void

    init(onSelect: @escaping (BookEntity) -> Void) {
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            List(books, id: \.persistentModelID) { book in
                Button {
                    onSelect(book)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(book.title)
                                .font(.body)
                                .foregroundStyle(AppColors.textPrimary)
                            if let author = book.author, !author.isEmpty {
                                Text(author)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        Spacer()
                    }
                }
                .accessibilityIdentifier("Focus.BookPicker.Row.\(String(describing: book.persistentModelID))")
            }
            .navigationTitle(Text(LocalizedStringKey("focus.picker.nav")))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) { dismiss() }
                }
            }
        }
    }
}

// MARK: - Haptics Helper
private extension FocusModeView {
    enum HapticKind { case success, warning, light, selection }

    func triggerHaptic(_ kind: HapticKind) {
        guard hapticsEnabled else { return }
        #if os(iOS)
        switch kind {
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
        #endif
    }
}
