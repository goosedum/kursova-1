//
//  TitleCompanySearch.swift
//  Параметри функції 1: поля «Посада» і «Компанія».
//

import SwiftUI

/// Два поля функції 1 (Figma: `Molecule/TitleCompanySearch`, екран S-03). Порожнє поле — будь-яке значення (D-09).
struct TitleCompanySearch: View {

    /// Функція 1. `@Bindable` — поля змінюють її властивості напряму (операції `@Observable`, D-35).
    @Bindable var operation: SearchByTitleAndCompanyOperation
    /// Що зробити, коли в полі натиснули ⏎.
    let onSubmit: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: AppSpacing.m) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                FieldLabel(text: "Посада")
                TextField("Наприклад, developer", text: $operation.titleQuery)
                    .frame(width: 180)
                    .onSubmit(onSubmit)
            }
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                FieldLabel(text: "Компанія")
                TextField("Наприклад, byte", text: $operation.companyQuery)
                    .frame(width: 180)
                    .onSubmit(onSubmit)
            }
        }
    }
}
