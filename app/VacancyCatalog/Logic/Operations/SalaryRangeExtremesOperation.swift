//
//  SalaryRangeExtremesOperation.swift
//  Функція 5: вакансії з найменшим і найбільшим діапазоном зарплати, з урахуванням однакових значень.
//

import Foundation
import Observation

/// Функція 5 — вакансії з найменшим і найбільшим діапазоном зарплати (діапазон = макс − мін).
///
/// Якщо однаковий крайній діапазон мають кілька вакансій, показуються **всі** вони. Результат — дві групи;
/// якщо в усіх вакансій діапазон однаковий (або вакансія одна) — одна група «Однаковий діапазон» (D-36).
@Observable
class SalaryRangeExtremesOperation: CatalogOperation {

    init() {
        super.init(title: "Найменший і найбільший діапазон зарплати",
                   shortTitle: "Діапазон зарплати",
                   systemImage: "arrow.left.and.right",
                   helpText: "Діапазон = макс − мін. Показано всі вакансії з крайніми значеннями, зокрема однакові.")
    }

    /// Знаходить найменший і найбільший діапазон і всі вакансії з такими діапазонами (у порядку каталогу).
    ///
    /// - Throws: `VacancyError.emptyCatalog`, якщо каталог порожній.
    func findExtremes(in catalog: VacancyCatalog) throws -> SalaryRangeExtremes {
        try checkNotEmpty(catalog)
        let vacancies = catalog.vacancies

        // 1. Перший прохід: найменше і найбільше значення діапазону
        var minRange = vacancies[0].salaryRange
        var maxRange = vacancies[0].salaryRange
        for vacancy in vacancies {
            if vacancy.salaryRange < minRange {
                minRange = vacancy.salaryRange
            }
            if vacancy.salaryRange > maxRange {
                maxRange = vacancy.salaryRange
            }
        }

        // 2. Другий прохід: усі вакансії з цими значеннями (так враховуються однакові)
        var minRangeVacancies: [Vacancy] = []
        var maxRangeVacancies: [Vacancy] = []
        for vacancy in vacancies {
            if vacancy.salaryRange == minRange {
                minRangeVacancies.append(vacancy)
            }
            if vacancy.salaryRange == maxRange {
                maxRangeVacancies.append(vacancy)
            }
        }
        return SalaryRangeExtremes(minRange: minRange, minRangeVacancies: minRangeVacancies,
                                   maxRange: maxRange, maxRangeVacancies: maxRangeVacancies)
    }

    /// - Throws: `VacancyError.emptyCatalog`, якщо каталог порожній.
    override func execute(on catalog: VacancyCatalog) throws -> OperationResult {
        let extremes = try findExtremes(in: catalog)

        if extremes.minRange == extremes.maxRange {
            // У всіх вакансій однаковий діапазон: найменший і найбільший збігаються, тому одна група
            // замість двох однакових — інакше ті самі вакансії повторилися б у таблиці (D-36)
            let sameGroup = VacancyGroup(title: "Однаковий діапазон",
                                         subtitle: "макс − мін = " + TextFormat.money(extremes.minRange),
                                         vacancies: extremes.minRangeVacancies)
            return OperationResult(title: "Найменший і найбільший діапазон",
                                   summary: "У всіх вакансій однаковий діапазон " + TextFormat.money(extremes.minRange),
                                   groups: [sameGroup])
        }

        let minGroup = VacancyGroup(title: "Найменший діапазон",
                                    subtitle: "макс − мін = " + TextFormat.money(extremes.minRange),
                                    vacancies: extremes.minRangeVacancies)
        let maxGroup = VacancyGroup(title: "Найбільший діапазон",
                                    subtitle: "макс − мін = " + TextFormat.money(extremes.maxRange),
                                    vacancies: extremes.maxRangeVacancies)

        let summary = "Мін. діапазон " + TextFormat.money(extremes.minRange) + " — "
            + TextFormat.vacancies(extremes.minRangeVacancies.count)
            + " · макс. " + TextFormat.money(extremes.maxRange) + " — "
            + TextFormat.vacancies(extremes.maxRangeVacancies.count)
        return OperationResult(title: "Найменший і найбільший діапазон", summary: summary, groups: [minGroup, maxGroup])
    }
}
