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
    @State private var title: String = ""
    @State private var author: String = ""

    /// Wird von der aufrufenden View gesetzt und führt die eigentliche Logik aus (VM → Repository).
    let onSave: (_ title: String, _ author: String?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "library.add.title.placeholder"), text: $title)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("addbook.title")

                TextField(String(localized: "library.add.author.placeholder"), text: $author)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("addbook.author")
            }
            .navigationTitle(Text("library.add.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                        .accessibilityIdentifier("addbook.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(trimmedTitle, trimmedAuthor.isEmpty ? nil : trimmedAuthor)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("addbook.save")
                }
            }
        }
    }
}
