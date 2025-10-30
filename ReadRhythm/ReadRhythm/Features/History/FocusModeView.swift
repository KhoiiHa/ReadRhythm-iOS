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
    @State private var timerAnimationToggle = false

    // We capture the initially provided book for assignment on appear.
    private let initialBook: BookEntity?

    init(sessionRepository: SessionRepository, initialBook: BookEntity? = nil) {
        self._vm = StateObject(
            wrappedValue: FocusModeViewModel(sessionRepository: sessionRepository)
        )
        self.initialBook = initialBook
    }

    var body: some View {
        VStack(spacing: AppSpace.xl) {

            // Header
            VStack(spacing: AppSpace.xs) {
                Text(LocalizedStringKey("focus.title"))
                    .font(AppFont.title)
                    .bold()
                    .accessibilityIdentifier("Focus.Title")

                Text(LocalizedStringKey("focus.subtitle"))
                    .font(AppFont.body)
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

                    VStack(alignment: .leading, spacing: AppSpace.xs) {
                        Text(LocalizedStringKey("focus.picker.title"))
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.textSecondary)

                        Text(
                            vm.selectedBook?.title
                            ?? String(localized: "focus.picker.choose")
                        )
                        .font(AppFont.body)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(AppSpace.md)
                .frame(maxWidth: .infinity)
                .background(AppColors.Semantic.bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.l)
                        .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                )
                .shadow(
                    color: AppShadow.card.color,
                    radius: AppShadow.card.radius,
                    x: AppShadow.card.x,
                    y: AppShadow.card.y
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("Focus.BookPicker")
            .sheet(isPresented: $showBookPicker) {
                BookPickerSheet { book in
                    vm.selectedBook = book
                    triggerHaptic(.selection)
                }
                .presentationDetents([.medium, .large])
            }

            // Timer Display
            Text(vm.formattedRemaining())
                .font(AppFont.titleLarge)
                .monospacedDigit()
                .padding(AppSpace.lg)
                .frame(maxWidth: .infinity)
                .background(AppColors.Semantic.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                )
                .shadow(
                    color: AppShadow.card.color,
                    radius: AppShadow.card.radius,
                    x: AppShadow.card.x,
                    y: AppShadow.card.y
                )
                .scaleEffect(timerAnimationToggle ? 1.0 : 0.98)
                .opacity(timerAnimationToggle ? 1.0 : 0.95)
                .animation(.easeInOut(duration: 0.2), value: timerAnimationToggle)
                .accessibilityIdentifier("Focus.Timer")

            // Duration Slider
            VStack(alignment: .leading, spacing: AppSpace.sm) {
                Text(LocalizedStringKey("focus.duration"))
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textSecondary)

                Slider(
                    value: Binding(
                        get: { Double(vm.durationMinutes) },
                        set: { vm.updateDuration(Int($0)) }
                    ),
                    in: 5...120,
                    step: 5
                )

                Text("\(vm.durationMinutes) " + String(localized: "goals.metric.minutes"))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpace.lg)
            .padding(.vertical, AppSpace.md)
            .background(AppColors.Semantic.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.l)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
            )
            .shadow(
                color: AppShadow.card.color,
                radius: AppShadow.card.radius,
                x: AppShadow.card.x,
                y: AppShadow.card.y
            )

            // Controls
            HStack(spacing: AppSpace.md) {

                // Start / Resume
                Button {
                    #if DEBUG
                    DebugLogger.log("[Focus] Start/Resume pressed, duration=\(vm.durationMinutes)")
                    #endif
                    if vm.isRunning {
                        // already running, no-op
                    } else if vm.remainingSeconds == vm.durationMinutes * 60 {
                        // fresh start
                        vm.startSession()
                    } else {
                        // paused; resume
                        vm.resumeSession()
                    }
                    triggerHaptic(.success)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        timerAnimationToggle.toggle()
                    }
                } label: {
                    Label(
                        vm.isRunning
                        ? LocalizedStringKey("focus.action.running")
                        : LocalizedStringKey("focus.action.start"),
                        systemImage: "play.circle.fill"
                    )
                    .font(AppFont.body)
                    .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isRunning)
                .accessibilityIdentifier("Focus.StartResume")

                // Pause
                Button {
                    #if DEBUG
                    DebugLogger.log("[Focus] Pause pressed")
                    #endif
                    vm.pauseSession()
                    triggerHaptic(.light)
                } label: {
                    Label(LocalizedStringKey("focus.action.pause"), systemImage: "pause.circle")
                        .font(AppFont.body)
                }
                .buttonStyle(.bordered)
                .disabled(!vm.isRunning)
                .accessibilityIdentifier("Focus.Pause")

                // Finish & Save
                Button {
                    #if DEBUG
                    DebugLogger.log("[Focus] Finish pressed")
                    #endif
                    vm.stopSessionAndSave()
                    triggerHaptic(.success)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        timerAnimationToggle.toggle()
                    }
                } label: {
                    Label(LocalizedStringKey("focus.action.finish"), systemImage: "checkmark.circle")
                        .font(AppFont.body)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("Focus.Finish")

                // Stop / Reset (destructive, no save)
                Button(role: .destructive) {
                    #if DEBUG
                    DebugLogger.log("[Focus] Stop pressed")
                    #endif
                    vm.cancelSessionWithoutSave()
                    triggerHaptic(.warning)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        timerAnimationToggle.toggle()
                    }
                } label: {
                    Label(LocalizedStringKey("focus.action.stop"), systemImage: "stop.circle")
                        .font(AppFont.body)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("Focus.Stop")
            }

            Spacer()
        }
        .padding(.horizontal, AppSpace.lg)
        .padding(.bottom, AppSpace.xl)
        .background(AppColors.Semantic.bgPrimary.ignoresSafeArea())
        .navigationTitle(Text(LocalizedStringKey("focus.nav.title")))
        .onAppear {
            if vm.selectedBook == nil {
                vm.selectedBook = initialBook
            }
        }
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

                            // author is now a non-optional String on BookEntity
                            if !book.author.isEmpty {
                                Text(book.author)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        Spacer()
                    }
                }
                .accessibilityIdentifier(
                    "Focus.BookPicker.Row.\(String(describing: book.persistentModelID))"
                )
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

#if DEBUG
import SwiftData

struct FocusModeView_Previews: PreviewProvider {
    static var previews: some View {

        // 1. In-Memory SwiftData Container für Preview bauen
        let models: [any PersistentModel.Type] = ReadRhythmSchemaV2.models
        let schema = Schema(models)
        let container = try! ModelContainer(
            for: schema,
            migrationPlan: ReadRhythmMigrationPlan.self,
            configurations: ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
        )

        // 2. Einen ModelContext ableiten
        let previewContext = ModelContext(container)

        // 3. Dummy-Buch einfügen
        let demoBook = BookEntity(
            sourceID: "demo-id",
            title: "Atomic Habits",
            author: "James Clear",
            thumbnailURL: nil,
            source: "userAdded"
        )
        previewContext.insert(demoBook)

        // 4. Lokales Mock-Repository für Preview
        struct PreviewSessionRepository: SessionRepository {
            @discardableResult
            func saveSession(book: BookEntity?, minutes: Int, date: Date, medium: String) throws -> ReadingSessionEntity {
                #if DEBUG
                DebugLogger.log("🧪 [Preview] saveSession(\(minutes)min, \(medium)) book=\(book?.title ?? "nil")")
                #endif
                return ReadingSessionEntity(
                    date: date,
                    minutes: minutes,
                    book: book,
                    medium: medium
                )
            }

            @discardableResult
            func addSession(for book: BookEntity, minutes: Int, date: Date) throws -> ReadingSessionEntity {
                try saveSession(book: book, minutes: minutes, date: date, medium: "reading")
            }

            func deleteSession(_ session: ReadingSessionEntity) throws {
                #if DEBUG
                DebugLogger.log("🧪 [Preview] deleteSession id=\(session.id)")
                #endif
            }
        }

        // 5. View mit injiziertem Repository
        return FocusModeView(
            sessionRepository: PreviewSessionRepository(),
            initialBook: demoBook
        )
        .modelContainer(container)
    }
}
#endif
