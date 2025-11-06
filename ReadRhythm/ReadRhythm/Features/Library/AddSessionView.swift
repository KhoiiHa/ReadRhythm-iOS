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

    private var footerHint: some View {
        Text("session.add.hint")
            .font(AppFont.caption2())
            .foregroundStyle(AppColors.Semantic.textSecondary)
            .multilineTextAlignment(.leading)
    }

    private let minMinutes = 1
    private let maxMinutes = 1440 // 24h Obergrenze als sanfter Guard

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpace._24) {
                    // Sektionstitel
                    Text("session.add.section.info")
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .accessibilityIdentifier("session.add.section")

                    // Card mit Feldern
                    VStack(alignment: .leading, spacing: AppSpace._16) {
                        DatePicker(
                            "session.add.date",
                            selection: $date,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .accessibilityIdentifier("session.add.date")

                        VStack(alignment: .leading, spacing: AppSpace._6) {
                            Text("session.add.minutes")
                                .font(AppFont.bodyStandard(.semibold))
                            TextField(String(localized: "session.add.minutes.placeholder"), text: $minutesText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .focused($focused, equals: .minutes)
                                .accessibilityIdentifier("session.add.minutes")
                                .onChange(of: minutesText) { oldValue, newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered != newValue { minutesText = filtered }
                                    if let m = Int(filtered), m > maxMinutes { minutesText = String(maxMinutes) }
                                }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityHint(Text("session.add.minutes.hint"))
                        .accessibilityValue(Text(minutesText.isEmpty ? "0" : minutesText))
                    }
                    .padding(AppSpace._16)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                            .fill(AppColors.Semantic.bgCard)
                            .shadow(
                                color: AppColors.Semantic.shadowColor.opacity(0.12),
                                radius: 10,
                                x: 0,
                                y: 6
                            )
                    )

                    footerHint
                        .padding(.horizontal, AppSpace._4)

                    Spacer(minLength: AppSpace._16)
                }
                .padding(.horizontal, AppSpace._16)
                .padding(.top, AppSpace._20)
                .padding(.bottom, AppSpace._24)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.Semantic.bgScreen.ignoresSafeArea())
            .navigationTitle(Text("session.add.title"))
            .navigationBarTitleDisplayMode(.inline)
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
