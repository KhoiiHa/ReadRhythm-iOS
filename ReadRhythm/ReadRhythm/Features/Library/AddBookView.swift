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

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("library.add.section.info")) {
                    TextField(String(localized: "library.add.title.placeholder"), text: $title)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .title)
                        .onSubmit { focusedField = .author }
                        .accessibilityIdentifier("addbook.title")

                    TextField(String(localized: "library.add.author.placeholder"), text: $author)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .author)
                        .onSubmit { performSave() }
                        .accessibilityIdentifier("addbook.author")
                }
                .textCase(nil)
                .accessibilityIdentifier("addbook.section.info")

                Section(footer: Text("library.add.hint")) {
                    EmptyView()
                }
            }
            .navigationTitle(Text("library.add.title"))
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColors.Semantic.bgPrimary)
            .tint(AppColors.Semantic.tintPrimary)
            .scrollDismissesKeyboard(.interactively)
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                        .accessibilityIdentifier("addbook.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") { performSave() }
                        .disabled(trimmedTitle.isEmpty)
                        .accessibilityIdentifier("addbook.save")
                }
            }
            .onAppear { focusedField = .title }
        }
    }

    // MARK: - Helpers
    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedAuthor: String { author.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func performSave() {
        guard trimmedTitle.isEmpty == false else { return }
        onSave(trimmedTitle, trimmedAuthor.isEmpty ? nil : trimmedAuthor)
        dismiss()
    }
}

