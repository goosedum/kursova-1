//
//  SearchByTitleAndCompanyOperationTests.swift
//  Тести функції 1: пошук за посадою і компанією на демо-файлі.
//

import Testing
@testable import VacancyCatalog

/// Тести `SearchByTitleAndCompanyOperation` (T-CAT-01…03; еталон — `docs/analysis/03-test-data.md`).
@MainActor
struct SearchByTitleAndCompanyOperationTests {

    /// Номери знайдених вакансій.
    private func search(title: String, company: String, in catalog: VacancyCatalog) throws -> [Int] {
        let operation = SearchByTitleAndCompanyOperation()
        operation.titleQuery = title
        operation.companyQuery = company
        let result = try operation.execute(on: catalog)
        return TestFiles.numbers(of: result.groups[0].vacancies, in: catalog)
    }

    @Test("T-CAT-01: «developer» + «byte» → № 1, 2 (№ 24 — Engineer, не підходить)")
    func bothFields() throws {
        let catalog = try TestFiles.demoCatalog()
        let operation = SearchByTitleAndCompanyOperation()
        operation.titleQuery = "developer"
        operation.companyQuery = "byte"
        let result = try operation.execute(on: catalog)

        #expect(TestFiles.numbers(of: result.groups[0].vacancies, in: catalog) == [1, 2])
        #expect(result.title == "Посада «developer» і компанія «byte»")
        #expect(result.summary == "Знайдено 2 вакансії")
        #expect(result.groups.count == 1)
        #expect(result.groups[0].title.isEmpty)
    }

    @Test("T-CAT-02: заповнене лише одне поле (D-09)")
    func oneField() throws {
        let catalog = try TestFiles.demoCatalog()
        #expect(try search(title: "", company: "cloud", in: catalog) == [8, 18, 27])
        #expect(try search(title: "frontend", company: "", in: catalog) == [5, 6, 22])
    }

    @Test("T-CAT-03: регістр і пробіли не важливі; нічого не знайдено")
    func caseAndNothingFound() throws {
        let catalog = try TestFiles.demoCatalog()
        #expect(try search(title: "  DEVELOPER ", company: "Byte", in: catalog) == [1, 2])

        let operation = SearchByTitleAndCompanyOperation()
        operation.titleQuery = "Rust"
        let result = try operation.execute(on: catalog)
        #expect(result.groups[0].vacancies.isEmpty)
        #expect(result.summary == "Нічого не знайдено")
    }

    @Test("T-CAT-13: порожній каталог → emptyCatalog (D-38)")
    func emptyCatalogThrows() {
        let operation = SearchByTitleAndCompanyOperation()
        operation.titleQuery = "developer"
        #expect(throws: VacancyError.emptyCatalog) {
            try operation.execute(on: VacancyCatalog())
        }
    }

    @Test("Кнопка «Виконати» активна, лише коли заповнене хоча б одне поле")
    func canExecuteNeedsOneField() {
        let operation = SearchByTitleAndCompanyOperation()
        #expect(operation.canExecute == false)
        operation.titleQuery = "   "
        #expect(operation.canExecute == false)
        operation.companyQuery = "byte"
        #expect(operation.canExecute)
    }
}
