//
//  SearchByTitleAndCompanyOperation.swift
//  Функція 1: пошук вакансій за назвою посади та компанією.
//

import Foundation
import Observation

/// Функція 1 — пошук за назвою посади **та** компанією (рішення D-09).
///
/// Вакансія підходить, якщо її посада містить `titleQuery` **і** компанія містить `companyQuery`
/// (регістр не важливий, пробіли по краях відкидаються). Порожнє поле — будь-яке значення.
@Observable
class SearchByTitleAndCompanyOperation: CatalogOperation {

    /// Текст, який має містити назва посади.
    var titleQuery = ""
    /// Текст, який має містити назва компанії.
    var companyQuery = ""

    init() {
        super.init(title: "Пошук за посадою і компанією",
                   shortTitle: "Посада і компанія",
                   systemImage: "magnifyingglass",
                   helpText: "Посада і компанія мають містити введений текст (регістр не важливий). "
                       + "Порожнє поле — будь-яке значення.")
    }

    /// Хоча б одне поле має бути заповнене.
    override var canExecute: Bool {
        let title = titleQuery.trimmingCharacters(in: .whitespaces)
        let company = companyQuery.trimmingCharacters(in: .whitespaces)
        return title.isEmpty == false || company.isEmpty == false
    }

    /// - Throws: `VacancyError.emptyCatalog`, якщо каталог порожній (D-38).
    override func execute(on catalog: VacancyCatalog) throws -> OperationResult {
        try checkNotEmpty(catalog)
        let title = titleQuery.trimmingCharacters(in: .whitespaces)
        let company = companyQuery.trimmingCharacters(in: .whitespaces)

        // Обидві умови разом («та»)
        var found: [Vacancy] = []
        for vacancy in catalog.vacancies {
            if text(vacancy.title, contains: title) && text(vacancy.company, contains: company) {
                found.append(vacancy)
            }
        }
        return searchResult(title: describe(title: title, company: company), found: found)
    }

    /// Чи містить `text` рядок `query` без урахування регістру. Порожній `query` підходить до будь-якого тексту.
    private func text(_ text: String, contains query: String) -> Bool {
        if query.isEmpty {
            return true
        }
        return text.lowercased().contains(query.lowercased())
    }

    /// Опис запиту для заголовка результату.
    private func describe(title: String, company: String) -> String {
        if title.isEmpty == false && company.isEmpty == false {
            return "Посада «\(title)» і компанія «\(company)»"
        }
        if title.isEmpty == false {
            return "Посада «\(title)»"
        }
        if company.isEmpty == false {
            return "Компанія «\(company)»"
        }
        return "Усі вакансії"
    }
}
