//
//  AddSessionView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import SwiftUI

/// Leichtgewichtiges Add-Formular für Lese-Sessions (MVP-ready).
/// Warum → Wie
/// - Warum: Konsistente UX zum AddBook-Flow, klare Validierung, Theme/i18n/A11y.
/// - Wie: Form mit DatePicker + Minutenfeld, sanfte Validierung, Save nur wenn gültig.
struct AddSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Field?

    @State private var date: Date = .now
    @State private var minutesText: String = ""

    /// Callback ins aufrufende ViewModel (z. B. BookDetailViewModel.addSession)
    let onSave: (_ minutes: Int, _ date: Date) -> Void

    enum Field { case minutes }

    private let minMinutes = 1
    private let maxMinutes = 1440 // 24h Obergrenze als sanfter Guard

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("session.add.section.info")) {
                    DatePicker(
                        "session.add.date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("session.add.date")

                    HStack {
                        Text("session.add.minutes")
                        TextField(String(localized: "session.add.minutes.placeholder"), text: $minutesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focused, equals: .minutes)
                            .accessibilityIdentifier("session.add.minutes")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityHint(Text("session.add.minutes.hint"))
                    .accessibilityValue(Text(minutesText.isEmpty ? "0" : minutesText))
                    .onChange(of: minutesText) { oldValue, newValue in
                        // Nur Ziffern erlauben und weich auf max cappen
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue { minutesText = filtered }
                        if let m = Int(filtered), m > maxMinutes { minutesText = String(maxMinutes) }
                    }
                }
                .textCase(nil)
                .accessibilityIdentifier("session.add.section")

                Section(footer: Text("session.add.hint")) {
                    EmptyView()
                }
            }
            .navigationTitle(Text("session.add.title"))
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColors.Semantic.bgScreen)
            .tint(AppColors.Semantic.tintPrimary)
            .scrollDismissesKeyboard(.interactively)
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                        .font(AppFont.bodyStandard())
                        .accessibilityIdentifier("session.add.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") { performSave() }
                        .font(AppFont.bodyStandard())
                        .disabled(!isValid)
                        .accessibilityIdentifier("session.add.save")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("common.done") { focused = nil }
                        .font(AppFont.bodyStandard())
                        .accessibilityIdentifier("session.add.keyboard.done")
                }
            }
            .onAppear { focused = .minutes }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Helpers
    private var isValid: Bool {
        guard let m = Int(minutesText), m >= minMinutes, m <= maxMinutes else { return false }
        return true
    }

    private func performSave() {
        guard let m = Int(minutesText), m >= minMinutes, m <= maxMinutes else { return }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        #if DEBUG
        print("📝 [AddSession] save minutes=\(m) date=\(date.ISO8601Format())")
        #endif
        onSave(m, date)
        dismiss()
    }
}
