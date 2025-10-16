//
//  LibraryView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack {
            Text("Library – Platzhalter")
                .padding()
                .accessibilityIdentifier("library.view")

            #if DEBUG
            Button("+Demo Book (DEBUG)") {
                let book = BookEntity(
                    id: UUID(),
                    title: "Debug Sample Book",
                    author: "System",
                    createdAt: Date()
                )
                context.insert(book)
                try? context.save()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("library.debug.addBook")
            #endif
        }
    }
}
