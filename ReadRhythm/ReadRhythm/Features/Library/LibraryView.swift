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

    // Sortierung nach Hinzugefügt-am-Datum (neueste zuerst).
    @Query(sort: [SortDescriptor(\BookEntity.dateAdded, order: .reverse)])
    private var books: [BookEntity]

    var body: some View {
        Group {
            if books.isEmpty {
                LibraryEmptyStateView {
                    // Öffnet das Add-Sheet
                    viewModel.showAddSheet = true
                }
            } else {
                List {
                    ForEach(books) { book in
                        NavigationLink(value: book) {
                            BookRowView(book: book)
                        }
                        .listRowInsets(
                            EdgeInsets(
                                top: AppSpace._8,
                                leading: AppSpace._16,
                                bottom: AppSpace._8,
                                trailing: AppSpace._16
                            )
                        )
                        .listRowBackground(AppColors.Semantic.bgScreen)
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
                .listRowSeparator(.hidden)
                .scrollContentBackground(.hidden)
                .background(AppColors.Semantic.bgScreen)
            }
        }
        .background(AppColors.Semantic.bgScreen)
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
        .accessibilityIdentifier("library.view")
        .overlay(alignment: .bottom) {
            if let key = viewModel.toastMessageKey {
                Text(LocalizedStringKey(key))
                    .font(AppFont.caption2())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.Semantic.bgCard)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        AppColors.Semantic.chipBg.opacity(0.6),
                                        lineWidth: AppStroke.cardBorder
                                    )
                            )
                    )
                    .foregroundStyle(AppColors.Semantic.chipFg)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.2), value: viewModel.toastMessageKey)
                    .accessibilityIdentifier("toast.\(key)")
            }
        }
        .onAppear {
            // Einmalig den echten SwiftData-Context an das Repository binden
            viewModel.bind(context: modelContext)
        }
    }
}

private struct LibraryEmptyStateView: View {
    let onAddTapped: () -> Void

    var body: some View {
        VStack(spacing: AppSpace._12) {
            Image(systemName: "books.vertical")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.Semantic.textSecondary)

            Text(LocalizedStringKey("library.empty.title"))
                .font(AppFont.headingS())

            Text(LocalizedStringKey("library.empty.subtitle"))
                .font(AppFont.bodyStandard())
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpace._16)

            Button {
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                onAddTapped()
            } label: {
                Label(LocalizedStringKey("library.empty.add"), systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("library.empty.add")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, AppSpace._16)
        .background(AppColors.Semantic.bgScreen)
        .accessibilityIdentifier("library.emptyState")
    }
}
