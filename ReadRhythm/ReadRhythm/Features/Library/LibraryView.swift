//  LibraryView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import SwiftUI
import SwiftData
import UIKit

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
                    BookRowView(book: book)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        // Haptik + Delete-Logik über bestehendes ViewModel API
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        if let idx = books.firstIndex(where: { $0.persistentModelID == book.persistentModelID }) {
                            viewModel.delete(at: IndexSet(integer: idx), from: books)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(Color("accent.error"))
                }
            }
            .onDelete { offsets in
                viewModel.delete(at: offsets, from: books)
            }
            .accessibilityIdentifier("library.list")
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppColors.Semantic.bgPrimary)
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
