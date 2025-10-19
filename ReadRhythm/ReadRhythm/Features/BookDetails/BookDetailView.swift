//
//  BookDetailView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//


//
//  BookDetailView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI
import SwiftData

/// Kontext → Warum → Wie
/// - Kontext: Detailansicht eines Buchs mit Lesesessions.
/// - Warum: Kernfluss Library → Detail → Session; zeigt Fortschritt und erlaubt neue Sessions.
/// - Wie: Theme-konsistenter Header, kompakte Stats, Session-Liste, Add-Session-Sheet. i18n/A11y-ready.
struct BookDetailView: View {
    let book: BookEntity

    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = BookDetailViewModel()

    // MARK: - Derived
    private var sessionsSorted: [ReadingSessionEntity] {
        book.sessions.sorted { $0.date > $1.date }
    }
    private var totalMinutes: Int { sessionsSorted.reduce(0) { $0 + $1.minutes } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace._16) {
                header
                stats
                sessionsSection
            }
            .padding(.horizontal, AppSpace._16)
            .padding(.vertical, AppSpace._16)
        }
        .background(AppColors.Semantic.bgPrimary)
        .navigationTitle(Text("book.detail.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { addSessionToolbar }
        .onAppear { viewModel.bind(context: context) }
        // Sheet: Add Session
        .sheet(isPresented: $viewModel.showAddSessionSheet) {
            AddSessionView { minutes, date in
                viewModel.addSession(for: book, minutes: minutes, date: date)
            }
        }
        // Fehler-Alert (i18n)
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
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpace._12) {
            // Dein kompakter Titel-/Autor-Header
            BookHeaderView(title: book.title, author: book.author)

            // CTA in eigener Zeile, links ausgerichtet + Top-Padding
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.showAddSessionSheet = true
                } label: {
                    Label(String(localized: "session.add.cta"), systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.Semantic.tintPrimary)
                .accessibilityIdentifier("bookdetail.addsession")

                Spacer(minLength: 0)
            }
            .padding(.top, AppSpace._12)
        }
    }

    // MARK: - Stats
    private var stats: some View {
        HStack(spacing: AppSpace._16) {
            statTile(titleKey: "book.detail.sessions", value: "\(sessionsSorted.count)")
            statTile(titleKey: "book.detail.minutes", value: "\(totalMinutes)")
            Spacer(minLength: 0)
        }
    }

    private func statTile(titleKey: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpace._4) {
            Text(value)
                .font(.title3).bold()
                .foregroundStyle(AppColors.Semantic.textPrimary)
            Text(titleKey)
                .font(.footnote)
                .foregroundStyle(AppColors.Semantic.textSecondary)
        }
        .padding(AppSpace._12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.m)
                .fill(AppColors.Semantic.bgElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.m)
                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Sessions List
    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpace._8) {
            Text("book.detail.sessions.header")
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityIdentifier("bookdetail.sessions.header")

            if sessionsSorted.isEmpty {
                Text("book.detail.sessions.empty")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .padding(.vertical, AppSpace._8)
                    .accessibilityIdentifier("bookdetail.sessions.empty")
            } else {
                ForEach(sessionsSorted) { session in
                    SessionRow(date: session.date, minutes: session.minutes)
                        .padding(.vertical, AppSpace._8)
                        .accessibilityIdentifier("bookdetail.session.row")
                    Divider()
                        .overlay(AppColors.Semantic.borderMuted)
                }
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var addSessionToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.showAddSessionSheet = true
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityIdentifier("bookdetail.addsession.toolbar")
        }
    }
}

