//
//  FieldLabel.swift
//  Атом «підпис над полем» для панелей параметрів функцій (Figma: FormRow, layout = stacked).
//

import SwiftUI

/// Невеликий сірий напівжирний підпис над полем: «Посада», «Технологія», «Напрям».
///
/// У формі вакансії підписи стоять ліворуч від полів — це робить системна `Form`, тому там цей атом не потрібен.
struct FieldLabel: View {

    /// Текст підпису.
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}

#Preview("FieldLabel") {
    FieldLabel(text: "Компанія")
        .padding()
}
