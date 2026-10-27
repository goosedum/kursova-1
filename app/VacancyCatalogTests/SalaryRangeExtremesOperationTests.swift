//
//  SalaryRangeExtremesOperationTests.swift
//  Тести функції 5: найменший і найбільший діапазон зарплати з урахуванням однакових значень.
//

import Testing
@testable import VacancyCatalog

/// Тести `SalaryRangeExtremesOperation` (T-CAT-10…13; еталон — `docs/analysis/03-test-data.md`).
@MainActor
struct SalaryRangeExtremesOperationTests {

    /// Каталог з вакансій із заданими зарплатами (мін, макс).
    private func makeCatalog(_ salaries: [(Int, Int)]) throws -> VacancyCatalog {
        let catalog = VacancyCatalog()
        for (minSalary, maxSalary) in salaries {
            try catalog.add(Vacancy(company: "Company", title: "Developer", specialization: "Backend",
                                    experienceLevel: .middle, minSalary: minSalary, maxSalary: maxSalary,
                                    workFormat: .remote, technologies: ["Swift"]))
        }
        return catalog
    }

    @Test("T-CAT-10, 11: демо-файл — найменший 300 (№ 7, 10, 12), найбільший 3000 (№ 4, 16)")
    func demoFile() throws {
        let catalog = try TestFiles.demoCatalog()
        let operation = SalaryRangeExtremesOperation()

        let extremes = try operation.findExtremes(in: catalog)
        #expect(extremes.minRange == 300)
        #expect(TestFiles.numbers(of: extremes.minRangeVacancies, in: catalog) == [7, 10, 12])
        #expect(extremes.maxRange == 3000)
        #expect(TestFiles.numbers(of: extremes.maxRangeVacancies, in: catalog) == [4, 16])

        let result = try operation.execute(on: catalog)
        #expect(result.groups.count == 2)
        #expect(result.groups[0].title == "Найменший діапазон")
        #expect(result.groups[0].subtitle == "макс − мін = $300")
        #expect(result.groups[1].title == "Найбільший діапазон")
        #expect(result.groups[1].subtitle == "макс − мін = $3 000")
        #expect(result.summary == "Мін. діапазон $300 — 3 вакансії · макс. $3 000 — 2 вакансії")
    }

    @Test("T-CAT-12: у всіх однаковий діапазон — обидві групи містять усі вакансії")
    func allRangesEqual() throws {
        let catalog = try makeCatalog([(1000, 2000), (3000, 4000), (500, 1500)])
        let result = try SalaryRangeExtremesOperation().execute(on: catalog)
        #expect(result.groups[0].vacancies.count == 3)
        #expect(result.groups[1].vacancies.count == 3)
        #expect(result.summary == "У всіх вакансій однаковий діапазон $1 000")
    }

    @Test("Одна вакансія — вона в обох групах")
    func singleVacancy() throws {
        let catalog = try makeCatalog([(800, 1200)])
        let extremes = try SalaryRangeExtremesOperation().findExtremes(in: catalog)
        #expect(extremes.minRangeVacancies[0] === catalog.vacancies[0])
        #expect(extremes.maxRangeVacancies[0] === catalog.vacancies[0])
    }

    @Test("Нульовий діапазон (мін = макс) теж враховується")
    func zeroRange() throws {
        let catalog = try makeCatalog([(1500, 1500), (1000, 2000), (700, 700)])
        let extremes = try SalaryRangeExtremesOperation().findExtremes(in: catalog)
        #expect(extremes.minRange == 0)
        #expect(TestFiles.numbers(of: extremes.minRangeVacancies, in: catalog) == [1, 3])
        #expect(extremes.maxRange == 1000)
    }

    @Test("T-CAT-13: порожній каталог → emptyCatalog")
    func emptyCatalogThrows() {
        #expect(throws: VacancyError.emptyCatalog) {
            try SalaryRangeExtremesOperation().execute(on: VacancyCatalog())
        }
    }
}
