//
//  SearchByTechnologyOperation.swift
//  Функція 2: пошук вакансій за технологією в переліку технологій.
//

import Foundation
import Observation

/// Функція 2 — пошук за технологією (рішення D-10).
///
/// Вакансія підходить, якщо в її переліку є технологія, що **дорівнює** введеній (без урахування регістру):
/// «Swift» не знаходить «SwiftUI», «Java» не знаходить «JavaScript».
@Observable
class SearchByTechnologyOperation: CatalogOperation {

    /// Назва технології, яку шукаємо.
    var technology = ""

    /// Функція 2 з порожнім полем технології. Назву, іконку й підказку передає базовому класу.
    init() {
        super.init(title: "Пошук за технологією",
                   shortTitle: "Технологія",
                   systemImage: "cpu",
                   helpText: "Точний збіг назви технології без урахування регістру: «Swift» не знаходить «SwiftUI». "
                       + "Поле підказує технології з каталогу.")
    }

    /// Поле технології має бути заповнене.
    override var canExecute: Bool {
        return technology.trimmingCharacters(in: .whitespaces).isEmpty == false
    }

    /// - Throws: `VacancyError.emptyCatalog`, якщо каталог порожній (D-38).
    override func execute(on catalog: VacancyCatalog) throws -> OperationResult {
        try checkNotEmpty(catalog)
        let name = technology.trimmingCharacters(in: .whitespaces)
        var found: [Vacancy] = []
        for vacancy in catalog.vacancies {
            if vacancy.hasTechnology(name) {
                found.append(vacancy)
            }
        }
        return searchResult(title: "Технологія «\(name)»", found: found)
    }
}
