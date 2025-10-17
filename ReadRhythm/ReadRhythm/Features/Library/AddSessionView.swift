//
//  AddSessionView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import SwiftUI

struct AddSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date = .now
    @State private var minutesText: String = ""
    let onSave: (_ minutes: Int, _ date: Date) -> Void

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Minutes", text: $minutesText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let minutes = Int(minutesText) ?? 0
                        onSave(minutes, date)
                        dismiss()
                    }
                    .disabled(Int(minutesText) == nil || (Int(minutesText) ?? 0) <= 0)
                }
            }
        }
    }
}
