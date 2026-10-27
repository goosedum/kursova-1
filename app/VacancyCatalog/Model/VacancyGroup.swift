//
//  VacancyGroup.swift
//  Група вакансій із заголовком — частина результату функцій 1–6.
//

import Foundation

/// Група вакансій із заголовком.
///
/// Результат функцій 1–4 — одна група без заголовка (звичайна таблиця), функції 5 — дві (найменший і найбільший
/// діапазон), функції 6 — по групі на кожну спеціалізацію.
struct VacancyGroup: Identifiable {
    /// Заголовок групи, наприклад «Backend» або «Найменший діапазон». Порожній — група показується без заголовка.
    let title: String
    /// Пояснення під заголовком, наприклад «макс − мін = $300». Може бути порожнім.
    let subtitle: String
    /// Вакансії групи (посилання на об'єкти з каталогу, не копії).
    let vacancies: [Vacancy]

    /// Створює групу; `subtitle` можна не вказувати.
    init(title: String, subtitle: String = "", vacancies: [Vacancy]) {
        self.title = title
        self.subtitle = subtitle
        self.vacancies = vacancies
    }

    /// Ідентифікатор для списків SwiftUI — заголовок, бо в межах одного результату він унікальний.
    var id: String {
        return title
    }
}
