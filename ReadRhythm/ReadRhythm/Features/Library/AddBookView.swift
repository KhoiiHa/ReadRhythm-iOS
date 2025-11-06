//
//  AddBookView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import SwiftUI

/// Leichtgewichtiges Add-Formular für Bücher.
/// UI-only: hält Eingaben lokal und meldet per Callback an das LibraryViewModel.
struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    @State private var title: String = ""
    @State private var author: String = ""

    /// Wird von der aufrufenden View gesetzt und führt die eigentliche Logik aus (VM → Repository).
    let onSave: (_ title: String, _ author: String?) -> Void

    enum Field { case title, author }

    private var footerHint: some View {
        Text("library.add.hint")
            .font(AppFont.caption2())
            .foregroundStyle(AppColors.Semantic.textSecondary)
            .multilineTextAlignment(.leading)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpace._24) {
                    // Sektionstitel (statt Form-Section-Header)
                    Text("library.add.section.info")
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .accessibilityIdentifier("addbook.section.info")

                    // Card mit den Eingabefeldern
                    VStack(alignment: .leading, spacing: AppSpace._16) {
                        TextField(String(localized: "library.add.title.placeholder"), text: $title)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                            .focused($focusedField, equals: .title)
                            .onSubmit { focusedField = .author }
                            .accessibilityIdentifier("addbook.title")

                        TextField(String(localized: "library.add.author.placeholder"), text: $author)
                            .textInputAutocapitalization(.words)
                            .textContentType(.name)
                            .submitLabel(.done)
                            .focused($focusedField, equals: .author)
                            .onSubmit { performSave() }
                            .accessibilityIdentifier("addbook.author")
                    }
                    .padding(AppSpace._16)
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

                    // Footer-Hinweis als eigener Block unterhalb der Card
                    footerHint
                        .padding(.horizontal, AppSpace._4)

                    Spacer(minLength: AppSpace._16)
                }
                .padding(.horizontal, AppSpace._16)
                .padding(.top, AppSpace._20)
                .padding(.bottom, AppSpace._24)
            }
            .background(AppColors.Semantic.bgScreen.ignoresSafeArea())
            .navigationTitle(Text("library.add.title"))
            .navigationBarTitleDisplayMode(.inline)
            .tint(AppColors.Semantic.tintPrimary)
            .scrollDismissesKeyboard(.interactively)
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                        .font(AppFont.bodyStandard())
                        .accessibilityIdentifier("addbook.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") { performSave() }
                        .font(AppFont.bodyStandard())
                        .disabled(!isSaveEnabled)
                        .accessibilityIdentifier("addbook.save")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("common.done") { focusedField = nil }
                        .accessibilityIdentifier("addbook.keyboard.done")
                }
            }
            .onAppear { focusedField = .title }
        }
    }

    // Save ist nur erlaubt, wenn der Titel mind. 2 Zeichen hat
    private var isSaveEnabled: Bool {
        trimmedTitle.count >= 2
    }

    // MARK: - Helpers
    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedAuthor: String { author.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func performSave() {
        guard isSaveEnabled else { return }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        onSave(trimmedTitle, trimmedAuthor.isEmpty ? nil : trimmedAuthor)
        dismiss()
    }
}
