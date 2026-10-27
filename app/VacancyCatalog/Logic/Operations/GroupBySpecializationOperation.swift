//
//  GroupBySpecializationOperation.swift
//  Функція 6: групування вакансій за спеціалізацією, у групі — за максимальною зарплатою.
//

import Foundation

/// Функція 6 — групування за спеціалізацією (рішення D-12).
///
/// Вакансії розкладаються в словник «спеціалізація → список». Групи йдуть за абеткою, у кожній групі —
/// від більшої максимальної зарплати до меншої (тим самим сортуванням злиттям). «Mobile» і «mobile» — одна група,
/// її назва — та, що трапилась першою.
class GroupBySpecializationOperation: CatalogOperation {

    init() {
        super.init(title: "Групування за спеціалізацією",
                   shortTitle: "Групи спеціалізацій",
                   systemImage: "rectangle.3.group",
                   helpText: "Групи за абеткою; у кожній групі — від більшої максимальної зарплати до меншої "
                       + "(сортування злиттям).")
    }

    /// - Throws: `VacancyError.emptyCatalog`, якщо каталог порожній.
    override func execute(on catalog: VacancyCatalog) throws -> OperationResult {
        try checkNotEmpty(catalog)

        // 1. Розкладаємо вакансії за спеціалізацією. Ключ словника — назва малими літерами,
        //    тому «Mobile» і «mobile» потрапляють в одну групу
        var vacanciesByKey: [String: [Vacancy]] = [:]
        var titleByKey: [String: String] = [:]
        for vacancy in catalog.vacancies {
            let key = vacancy.specialization.lowercased()
            if titleByKey[key] == nil {
                titleByKey[key] = vacancy.specialization
            }
            var list = vacanciesByKey[key] ?? []
            list.append(vacancy)
            vacanciesByKey[key] = list
        }

        // 2. Ключі словника не мають порядку — сортуємо їх за абеткою тим самим MergeSorter, але для рядків
        let keySorter = MergeSorter<String>()
        let sortedKeys = keySorter.sort(Array(vacanciesByKey.keys), by: { first, second in
            return first.localizedCompare(second) == .orderedAscending
        })

        // 3. У кожній групі — від більшої максимальної зарплати до меншої
        let vacancySorter = MergeSorter<Vacancy>()
        var groups: [VacancyGroup] = []
        for key in sortedKeys {
            let list = vacanciesByKey[key] ?? []
            let sorted = vacancySorter.sort(list, by: { first, second in
                return first.maxSalary > second.maxSalary
            })
            groups.append(VacancyGroup(title: titleByKey[key] ?? key, vacancies: sorted))
        }

        let summary = TextFormat.count(groups.count, one: "група", few: "групи", many: "груп")
        return OperationResult(title: "За спеціалізацією", summary: summary, groups: groups)
    }
}
