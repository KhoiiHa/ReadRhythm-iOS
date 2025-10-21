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
                            Spacer()
                            Text("\(draft)").monospacedDigit()
                                .accessibilityIdentifier("Goals.Edit.MinutesValue")
                        }
                    }
                    .accessibilityIdentifier("Goals.Edit.Stepper")
                } footer: {
                    Text("5–600 \(String(localized: "goals.edit.minutes").lowercased())")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(Text(LocalizedStringKey("goals.edit.title")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("goals.edit.cancel")) {
                        vm.isEditing = false
                        dismiss()
                    }
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

