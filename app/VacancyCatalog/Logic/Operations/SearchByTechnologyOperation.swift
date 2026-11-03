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

    /// Назва технології, яку шукаємо (те, що введено в поле).
    var technology = ""
    /// Технологія, за якою виконано останній пошук. Її виділяємо в результаті: поле можна вже змінити,
    /// а таблиця ще показує старий результат (дефект Ф-4).
    private(set) var searchedTechnology = ""

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
        searchedTechnology = name
        var found: [Vacancy] = []
        for vacancy in catalog.vacancies {
            if vacancy.hasTechnology(name) {
                found.append(vacancy)
            }
        }
        return searchResult(title: "Технологія «\(name)»", found: found)
    }

    /// Підказки для поля (дефект Ф-3): технології каталогу, що містять уведений текст (без регістру).
    ///
    /// Порожнє поле — усі технології. Коли текст уже дорівнює якійсь технології, підказок немає:
    /// значення введено, і список не закриває таблицю.
    func suggestions(from technologies: [String]) -> [String] {
        let query = technology.trimmingCharacters(in: .whitespaces).lowercased()
        var result: [String] = []
        for name in technologies {
            if name.lowercased() == query {
                return []
            }
            if query.isEmpty || name.lowercased().contains(query) {
                result.append(name)
            }
        }
        return result
    }
}
