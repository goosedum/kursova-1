//
//  SortByAverageSalaryOperationTests.swift
//  Тести функції 4: сортування за середньою зарплатою на демо-файлі.
//

import Testing
@testable import VacancyCatalog

/// Тести `SortByAverageSalaryOperation` (T-CAT-09, T-CAT-13; еталон — `docs/analysis/03-test-data.md`).
@MainActor
struct SortByAverageSalaryOperationTests {

    @Test("T-CAT-09: за спаданням (за замовчуванням); пари з однаковою середньою — у порядку файлу")
    func descendingByDefault() throws {
        let catalog = try TestFiles.demoCatalog()
        let operation = SortByAverageSalaryOperation()
        #expect(operation.ascending == false)

        let result = try operation.execute(on: catalog)
        #expect(TestFiles.numbers(of: result.groups[0].vacancies, in: catalog)
                == [4, 24, 16, 27, 2, 19, 6, 28, 14, 17, 26, 20, 8, 11, 9, 3, 23, 15, 5, 13, 18, 21, 1, 7, 25, 10, 12, 22])
        #expect(result.title == "За спаданням середньої зарплати")
        #expect(result.summary == "Відсортовано 28 вакансій")
    }

    @Test("T-CAT-09: за зростанням; каталог при цьому не змінився")
    func ascendingKeepsCatalog() throws {
        let catalog = try TestFiles.demoCatalog()
        let firstBefore = catalog.vacancies[0]
        let operation = SortByAverageSalaryOperation()
        operation.ascending = true

        let result = try operation.execute(on: catalog)
        #expect(TestFiles.numbers(of: result.groups[0].vacancies, in: catalog)
                == [22, 12, 10, 25, 7, 1, 21, 18, 13, 5, 15, 3, 23, 9, 8, 11, 20, 26, 14, 17, 6, 28, 19, 2, 27, 16, 24, 4])
        #expect(result.title == "За зростанням середньої зарплати")
        #expect(catalog.vacancies[0] === firstBefore)
        #expect(catalog.vacancies.count == 28)
    }

    @Test("T-CAT-13: порожній каталог → emptyCatalog")
    func emptyCatalogThrows() {
        #expect(throws: VacancyError.emptyCatalog) {
            try SortByAverageSalaryOperation().execute(on: VacancyCatalog())
        }
    }
}
