//  LibraryView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = LibraryViewModel()

    // Sortierung nach Erstellungsdatum (neueste zuerst). Passe an, falls dein Modell anders ist.
    @Query(sort: [SortDescriptor(\BookEntity.createdAt, order: .reverse)])
    private var books: [BookEntity]

    var body: some View {
        List {
            ForEach(books) { book in
                NavigationLink(value: book) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.headline)
                            .accessibilityIdentifier("library.row.title.\(book.persistentModelID.hashValue)")
                        if !book.author.isEmpty {
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("library.row.author.\(book.persistentModelID.hashValue)")
                        }
                    }
                }
            }
            .onDelete { offsets in
                viewModel.delete(at: offsets, from: books)
            }
            .accessibilityIdentifier("library.list")
        }
        .navigationTitle(Text("library.title"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { EditButton() }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("library.addBook.button")
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddBookView { title, author in
                viewModel.addBook(title: title, author: author)
            }
            .presentationDetents([.medium])
        }
        .navigationDestination(for: BookEntity.self) { book in
            BookDetailView(book: book)
        }
        .alert(Text("library.error.title"),
               isPresented: .constant(viewModel.errorMessageKey != nil)) {
            Button("common.ok") { viewModel.errorMessageKey = nil }
        } message: {
            if let key = viewModel.errorMessageKey {
                Text(key)
            }
        }
        .accessibilityIdentifier("library.view")
        .onAppear {
            // Einmalig den echten SwiftData-Context an das Repository binden
            viewModel.bind(context: modelContext)
        }
    }
}
