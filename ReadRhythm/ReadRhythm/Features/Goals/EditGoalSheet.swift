//
//  EditGoalSheet.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 21.10.25.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct EditGoalSheet: View {
    @ObservedObject var vm: ReadingGoalsViewModel
    @State private var draft: Int = 60
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $draft, in: 5...600, step: 5) {
                        HStack {
                            Text(LocalizedStringKey("goals.edit.minutes"))
                                .font(AppFont.bodyStandard())
                                .foregroundStyle(AppColors.Semantic.textPrimary)
                            Spacer()
                            Text("\(draft)").monospacedDigit()
                                .font(AppFont.bodyStandard())
                                .foregroundStyle(AppColors.Semantic.textPrimary)
                                .accessibilityIdentifier("Goals.Edit.MinutesValue")
                        }
                    }
                    .accessibilityIdentifier("Goals.Edit.Stepper")
                } footer: {
                    Text("5–600 \(String(localized: "goals.edit.minutes").lowercased())")
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.Semantic.bgScreen)
            .navigationTitle(Text(LocalizedStringKey("goals.edit.title")))
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.Semantic.bgScreen, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("goals.edit.cancel")) {
                        vm.isEditing = false
                        dismiss()
                    }
                    .font(AppFont.bodyStandard())
                    .accessibilityIdentifier("Goals.Edit.Cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("goals.edit.save")) {
                        let v = vm.validateTarget(draft)
                        let ok = vm.saveGoal(targetMinutes: v)
                        #if os(iOS)
                        if ok { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                        #endif
                        dismiss()
                    }
                    .font(AppFont.bodyStandard())
                    .accessibilityIdentifier("Goals.Edit.Save")
                }
            }
        }
        .onAppear {
            draft = vm.editTargetMinutes
            #if DEBUG
            print("[Goals] Edit sheet appeared with draft=\(draft)")
            #endif
        }
    }
}
