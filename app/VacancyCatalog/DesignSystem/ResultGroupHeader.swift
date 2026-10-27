//
//  ResultGroupHeader.swift
//  Молекула «заголовок групи результатів» (ф.5, ф.6): назва, кількість вакансій, пояснення.
//

import SwiftUI

/// Заголовок групи результатів (Figma: `Molecule/ResultGroupHeader`): «Mobile  6 вакансій»,
/// під ним — пояснення, якщо воно є («макс − мін = $300»).
struct ResultGroupHeader: View {

    /// Група, заголовок якої показуємо.
    let group: VacancyGroup

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.s) {
                Text(group.title)
                    .font(.title3.weight(.semibold))
                Text(TextFormat.vacancies(group.vacancies.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if group.subtitle.isEmpty == false {
                Text(group.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, AppSpacing.s)
        .padding(.bottom, AppSpacing.xs)
        // Для VoiceOver — заголовок: між групами можна переходити, як між заголовками
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview("ResultGroupHeader") {
    VStack(alignment: .leading) {
        ResultGroupHeader(group: VacancyGroup(title: "Mobile", vacancies: []))
        ResultGroupHeader(group: VacancyGroup(title: "Найменший діапазон", subtitle: "макс − мін = $300",
                                              vacancies: []))
    }
    .padding()
}
