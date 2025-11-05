//
//  MoreView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 03.11.25.
//

import SwiftUI
import SwiftData

struct MoreView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ProfileView(context: context)
                } label: {
                    Label("Profil", systemImage: "person.crop.circle")
                        .font(AppFont.bodyStandard())
                        .foregroundStyle(AppColors.Semantic.textPrimary)
                }

                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Einstellungen", systemImage: "gearshape")
                        .font(AppFont.bodyStandard())
                        .foregroundStyle(AppColors.Semantic.textPrimary)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppColors.Semantic.bgScreen)
            .listRowBackground(AppColors.Semantic.bgCard)
            .tint(AppColors.Semantic.tintPrimary)
            .navigationTitle(Text("More"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
