//
//  FieldErrorText.swift
//  Атом «помилка під полем»: червоний трикутник і текст помилки (Figma: FormRow, state = error).
//

import SwiftUI

/// Повідомлення про помилку під полем форми: ⚠ Поле «Компанія» не може бути порожнім.
struct FieldErrorText: View {

    /// Текст помилки (зазвичай `VacancyError.errorDescription`).
    let message: String

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .accessibilityHidden(true)
            Text(message)
        }
        .font(.subheadline)
        .foregroundStyle(AppColor.danger)
        // VoiceOver: «Помилка: Поле «Компанія» не може бути порожнім.»
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Помилка: " + message)
    }
}

#Preview("FieldErrorText") {
    FieldErrorText(message: "Поле «Компанія» не може бути порожнім.")
        .padding()
}
