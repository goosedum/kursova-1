//
//  FilterByLevelAndFormatOperation.swift
//  Функція 3: вакансії заданого рівня досвіду та формату роботи.
//

import Foundation
import Observation

/// Функція 3 — вакансії заданого рівня досвіду **та** формату роботи (обидві умови одночасно).
///
/// Рівень і формат вибираються зі списків, тому помилок введення тут не буває.
@Observable
class FilterByLevelAndFormatOperation: CatalogOperation {

    /// Потрібний рівень досвіду.
    var level = ExperienceLevel.middle
    /// Потрібний формат роботи.
    var format = WorkFormat.remote

    init() {
        super.init(title: "Рівень досвіду і формат роботи",
                   shortTitle: "Рівень і формат",
                   systemImage: "line.3.horizontal.decrease.circle",
                   helpText: "Вакансії, у яких збігаються обидва значення.")
    }

    override func execute(on catalog: VacancyCatalog) throws -> OperationResult {
        var found: [Vacancy] = []
        for vacancy in catalog.vacancies {
            if vacancy.experienceLevel == level && vacancy.workFormat == format {
                found.append(vacancy)
            }
        }
        return searchResult(title: "\(level.title) · \(format.title)", found: found)
    }
}
