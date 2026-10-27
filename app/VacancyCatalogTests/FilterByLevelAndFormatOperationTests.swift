//
//  FilterByLevelAndFormatOperationTests.swift
//  Тести функції 3: відбір за рівнем досвіду і форматом роботи на демо-файлі.
//

import Testing
@testable import VacancyCatalog

/// Тести `FilterByLevelAndFormatOperation` (T-CAT-07, 08; еталон — `docs/analysis/03-test-data.md`).
@MainActor
struct FilterByLevelAndFormatOperationTests {

    /// Номери вакансій з рівнем `level` і форматом `format`.
    private func filter(_ level: ExperienceLevel, _ format: WorkFormat, in catalog: VacancyCatalog) throws -> [Int] {
        let operation = FilterByLevelAndFormatOperation()
        operation.level = level
        operation.format = format
        let result = try operation.execute(on: catalog)
        return TestFiles.numbers(of: result.groups[0].vacancies, in: catalog)
    }

    @Test("T-CAT-07: обидві умови разом — Middle + Віддалено, Senior + Віддалено")
    func levelAndFormat() throws {
        let catalog = try TestFiles.demoCatalog()
        #expect(try filter(.middle, .remote, in: catalog) == [3, 5, 8, 11, 23])
        #expect(try filter(.senior, .remote, in: catalog) == [2, 14, 17, 19, 26, 27])

        let operation = FilterByLevelAndFormatOperation()
        operation.level = .middle
        operation.format = .remote
        let result = try operation.execute(on: catalog)
        #expect(result.title == "Middle · Віддалено")
        #expect(result.summary == "Знайдено 5 вакансій")
    }

    @Test("T-CAT-08: Intern + Гібрид → нічого не знайдено")
    func emptyResult() throws {
        let catalog = try TestFiles.demoCatalog()
        #expect(try filter(.intern, .hybrid, in: catalog).isEmpty)
    }

    @Test("Порожній каталог — порожній результат без винятку")
    func emptyCatalogGivesEmptyResult() throws {
        let result = try FilterByLevelAndFormatOperation().execute(on: VacancyCatalog())
        #expect(result.vacancyCount == 0)
        #expect(result.summary == "Нічого не знайдено")
    }
}
