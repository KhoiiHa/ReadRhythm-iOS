//
//  BookDetailView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import SwiftUI
import SwiftData

/// Read-only Detailansicht für ein Buch.
/// Dient als Ankerpunkt für den Session-Flow. (Add Session via Sheet)
struct BookDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = BookDetailViewModel()

    let book: BookEntity

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.title2)
                        .bold()
                        .accessibilityIdentifier("bookdetail.title")
                    if !book.author.isEmpty {
                        Text(book.author)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("bookdetail.author")
                    }
                }
            }

            Section {
                Button {
                    viewModel.showAddSessionSheet = true
                } label: {
                    Label("bookdetail.addsession", systemImage: "plus.circle.fill")
                }
                .accessibilityIdentifier("bookdetail.addsession.button")
            }
        }
        .navigationTitle(Text("bookdetail.title"))
        .accessibilityIdentifier("bookdetail.view")
        .sheet(isPresented: $viewModel.showAddSessionSheet) {
            AddSessionView { minutes, date in
                viewModel.addSession(for: book, minutes: minutes, date: date)
            }
        }
        .alert(Text("session.error.title"),
               isPresented: .constant(viewModel.errorMessageKey != nil)) {
            Button("common.ok") { viewModel.errorMessageKey = nil }
        } message: {
            if let key = viewModel.errorMessageKey { Text(key) }
        }
        .onAppear {
            viewModel.bind(context: modelContext)
        }
    }
}
