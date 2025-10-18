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
            
            // MARK: - Session-Liste
            /// Kontext → Warum → Wie:
            /// - Kontext: Zeigt alle ReadingSessions des aktuellen Buchs an.
            /// - Warum: Nutzer sollen ihre bisherigen Sessions einsehen und ggf. löschen können.
            /// - Wie: Sortiert nach Datum absteigend, Swipe-to-Delete über Repository-Aufruf.
            let sessions = book.sessions.sorted(by: { $0.date > $1.date })
            if !sessions.isEmpty {
                Section(header: Text("bookdetail.sessions")) {
                    ForEach(sessions) { session in
                        HStack {
                            Text(session.date, style: .date)
                            Spacer()
                            Text("\(session.minutes) min")
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityIdentifier("bookdetail.session.row")
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let session = sessions[index]
                            do {
                                try viewModel.deleteSession(session)
                            } catch {
                                viewModel.errorMessageKey = "session.error.delete"
                            }
                        }
                    }
                }
            } else {
                Section(header: Text("bookdetail.sessions")) {
                    VStack(alignment: .center, spacing: 8) {
                        Text("bookdetail.sessions.empty")
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("bookdetail.sessions.empty")

                        Button {
                            viewModel.showAddSessionSheet = true
                        } label: {
                            Label("bookdetail.addsession", systemImage: "plus.circle.fill")
                                .font(.footnote)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("bookdetail.addsession.cta")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(Text("bookdetail.title"))
        .accessibilityIdentifier("bookdetail.view")
        .sheet(
            isPresented: Binding(
                get: { viewModel.showAddSessionSheet },
                set: { viewModel.showAddSessionSheet = $0 }
            )
        ) {
            AddSessionView { minutes, date in
                viewModel.addSession(for: book, minutes: minutes, date: date)
            }
        }
        .alert(
            Text("session.error.title"),
            isPresented: Binding(
                get: { viewModel.errorMessageKey != nil },
                set: { if !$0 { viewModel.errorMessageKey = nil } }
            )
        ) {
            Button("common.ok") { viewModel.errorMessageKey = nil }
        } message: {
            if let key = viewModel.errorMessageKey { Text(key) }
        }
        .onAppear {
            viewModel.bind(context: modelContext)
        }
    }
}
