//
//  SearchByTechnologyOperationTests.swift
//  Тести функції 2: пошук за технологією на демо-файлі.
//

import Testing
@testable import VacancyCatalog

/// Тести `SearchByTechnologyOperation` (T-CAT-04…06; еталон — `docs/analysis/03-test-data.md`).
@MainActor
struct SearchByTechnologyOperationTests {

    /// Номери вакансій, у яких є технологія `name`.
    private func search(_ name: String, in catalog: VacancyCatalog) throws -> [Int] {
        let operation = SearchByTechnologyOperation()
        operation.technology = name
        let result = try operation.execute(on: catalog)
        return TestFiles.numbers(of: result.groups[0].vacancies, in: catalog)
    }

    @Test("T-CAT-04: «docker» → № 3, 4, 8, 17, 18, 19")
    func severalFound() throws {
        let catalog = try TestFiles.demoCatalog()
        let operation = SearchByTechnologyOperation()
        operation.technology = "docker"
        let result = try operation.execute(on: catalog)

        #expect(TestFiles.numbers(of: result.groups[0].vacancies, in: catalog) == [3, 4, 8, 17, 18, 19])
        #expect(result.title == "Технологія «docker»")
        #expect(result.summary == "Знайдено 6 вакансій")
    }

    @Test("T-CAT-05: регістр не важливий; «Swift» не знаходить «SwiftUI» (№ 11)")
    func exactMatchIgnoringCase() throws {
        let catalog = try TestFiles.demoCatalog()
        #expect(try search("SWIFT", in: catalog) == [1, 2, 24])
        #expect(try search(" swift ", in: catalog) == [1, 2, 24])
        #expect(try search("git", in: catalog) == [1, 2, 5, 6, 9, 11, 12, 18, 21, 23])
    }

    @Test("T-CAT-06: такої технології немає → нічого не знайдено")
    func unknownTechnology() throws {
        let catalog = try TestFiles.demoCatalog()
        #expect(try search("Rust", in: catalog).isEmpty)
        // «Java» не знаходить «JavaScript»: лише вакансії, де є саме Java
        let java = try search("Java", in: catalog)
        for number in java {
            #expect(catalog.vacancies[number - 1].hasTechnology("Java"))
        }
    }

    @Test("Кнопка «Виконати» активна, лише коли поле заповнене")
    func canExecuteNeedsTechnology() {
        let operation = SearchByTechnologyOperation()
        #expect(operation.canExecute == false)
        operation.technology = "  "
        #expect(operation.canExecute == false)
        operation.technology = "Swift"
        #expect(operation.canExecute)
    }
}
