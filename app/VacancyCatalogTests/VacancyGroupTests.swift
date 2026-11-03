//
//  VacancyGroupTests.swift
//  Тести групи вакансій: ідентифікатор для списків і пояснення за замовчуванням.
//

import Testing
@testable import VacancyCatalog

/// Тести структури `VacancyGroup`.
@MainActor
struct VacancyGroupTests {

    @Test("id — це заголовок групи; без пояснення subtitle порожній")
    func idAndDefaultSubtitle() {
        let group = VacancyGroup(title: "Mobile", vacancies: [])
        #expect(group.id == "Mobile")
        #expect(group.subtitle.isEmpty)
        #expect(VacancyGroup(title: "Найменший діапазон", subtitle: "макс − мін = $300", vacancies: []).subtitle
                == "макс − мін = $300")
    }
}
