//
//  GroupBySpecializationOperationTests.swift
//  Тести функції 6: групування за спеціалізацією, у групі — за максимальною зарплатою.
//

import Testing
@testable import VacancyCatalog

/// Тести `GroupBySpecializationOperation` (T-CAT-14…16; еталон — `docs/analysis/03-test-data.md`).
@MainActor
struct GroupBySpecializationOperationTests {

    @Test("T-CAT-14: 8 груп за абеткою")
    func groupsInAlphabeticalOrder() throws {
        let result = try GroupBySpecializationOperation().execute(on: TestFiles.demoCatalog())
        var titles: [String] = []
        for group in result.groups {
            titles.append(group.title)
        }
        #expect(titles == ["Backend", "Data Science", "Design", "DevOps", "Frontend", "Management", "Mobile", "QA"])
        #expect(result.summary == "8 груп")
        #expect(result.title == "За спеціалізацією")
    }

    @Test("T-CAT-15: у кожній групі — від більшої максимальної зарплати до меншої (D-12)")
    func vacanciesSortedByMaxSalary() throws {
        let catalog = try TestFiles.demoCatalog()
        let result = try GroupBySpecializationOperation().execute(on: catalog)
        let expected: [[Int]] = [
            [4, 3, 21],             // Backend
            [19, 20, 7, 12],        // Data Science
            [14, 13, 25],           // Design
            [27, 8, 18],            // DevOps
            [6, 5, 22],             // Frontend
            [16, 26, 15],           // Management
            [24, 2, 11, 9, 23, 1],  // Mobile
            [28, 17, 10]            // QA
        ]
        #expect(result.groups.count == expected.count)
        for index in 0..<result.groups.count {
            #expect(TestFiles.numbers(of: result.groups[index].vacancies, in: catalog) == expected[index])
        }
    }

    @Test("T-CAT-16: у групах разом стільки ж вакансій, скільки в каталозі")
    func everyVacancyInOneGroup() throws {
        let result = try GroupBySpecializationOperation().execute(on: TestFiles.demoCatalog())
        #expect(result.vacancyCount == 28)
    }

    @Test("«Mobile» і «mobile» — одна група з назвою, що трапилась першою")
    func caseInsensitiveGroups() throws {
        let catalog = VacancyCatalog()
        for specialization in ["Mobile", "Backend", "mobile"] {
            try catalog.add(Vacancy(company: "Company", title: "Developer", specialization: specialization,
                                    experienceLevel: .middle, minSalary: 1000, maxSalary: 2000,
                                    workFormat: .remote, technologies: ["Swift"]))
        }
        let result = try GroupBySpecializationOperation().execute(on: catalog)
        #expect(result.groups.count == 2)
        #expect(result.groups[1].title == "Mobile")
        #expect(result.groups[1].vacancies.count == 2)
        #expect(result.summary == "2 групи")
    }

    @Test("T-CAT-13: порожній каталог → emptyCatalog")
    func emptyCatalogThrows() {
        #expect(throws: VacancyError.emptyCatalog) {
            try GroupBySpecializationOperation().execute(on: VacancyCatalog())
        }
    }
}
