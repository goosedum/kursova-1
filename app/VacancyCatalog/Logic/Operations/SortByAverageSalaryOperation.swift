//
//  SortByAverageSalaryOperation.swift
//  Функція 4: сортування вакансій за середньою зарплатою методом злиття.
//

import Foundation

/// Функція 4 — сортування за середньою зарплатою (мін + макс) / 2 власним сортуванням злиттям (рішення D-11).
///
/// Показується відсортована копія масиву, сам каталог не змінюється. Сортування стабільне: вакансії з однаковою
/// середньою зарплатою лишаються в порядку файлу.
class SortByAverageSalaryOperation: CatalogOperation {

    /// `true` — від меншої до більшої; `false` (за замовчуванням) — від більшої до меншої.
    var ascending = false

    init() {
        super.init(title: "Сортування за середньою зарплатою",
                   shortTitle: "Сортування за ЗП",
                   systemImage: "arrow.up.and.down",
                   helpText: "Середня = (мін + макс) / 2. Власне сортування злиттям; рівні значення зберігають "
                       + "порядок файлу (стабільність).")
    }

    /// - Throws: `VacancyError.emptyCatalog`, якщо каталог порожній.
    override func execute(on catalog: VacancyCatalog) throws -> OperationResult {
        try checkNotEmpty(catalog)

        let sorter = MergeSorter<Vacancy>()
        var sorted: [Vacancy] = []
        var title = ""
        if ascending {
            sorted = sorter.sort(catalog.vacancies, by: { first, second in
                return first.averageSalary < second.averageSalary
            })
            title = "За зростанням середньої зарплати"
        } else {
            sorted = sorter.sort(catalog.vacancies, by: { first, second in
                return first.averageSalary > second.averageSalary
            })
            title = "За спаданням середньої зарплати"
        }

        let summary = "Відсортовано " + TextFormat.count(sorted.count, one: "вакансію", few: "вакансії", many: "вакансій")
        return OperationResult(title: title, summary: summary, groups: [VacancyGroup(title: "", vacancies: sorted)])
    }
}
