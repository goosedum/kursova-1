//
//  CatalogOperationTests.swift
//  Тести базового класу операцій: поліморфний виклик execute для всіх шести функцій.
//

import Testing
@testable import VacancyCatalog

/// Тести `CatalogOperation` (T-OP-01 з `.claude/plan/05-testing.md`).
@MainActor
struct CatalogOperationTests {

    /// Шість функцій у масиві базового типу — так їх тримає головне вікно.
    private func makeOperations() -> [CatalogOperation] {
        let search = SearchByTitleAndCompanyOperation()
        search.titleQuery = "developer"
        let technology = SearchByTechnologyOperation()
        technology.technology = "Swift"
        return [search, technology, FilterByLevelAndFormatOperation(), SortByAverageSalaryOperation(),
                SalaryRangeExtremesOperation(), GroupBySpecializationOperation()]
    }

    @Test("T-OP-01: один цикл виконує 6 різних функцій — спрацьовує execute кожного підкласу (поліморфізм)")
    func polymorphicExecute() throws {
        let catalog = try TestFiles.demoCatalog()
        var titles: [String] = []
        var groupCounts: [Int] = []
        for operation in makeOperations() {
            // Тип змінної — CatalogOperation, а виконується перевизначений метод підкласу
            let result = try operation.execute(on: catalog)
            titles.append(result.title)
            groupCounts.append(result.groups.count)
        }
        #expect(titles == ["Посада «developer»", "Технологія «Swift»", "Middle · Віддалено",
                           "За спаданням середньої зарплати", "Найменший і найбільший діапазон", "За спеціалізацією"])
        #expect(groupCounts == [1, 1, 1, 1, 2, 8])
    }

    @Test("Кожна функція має власні назву, коротку назву, іконку і підказку")
    func everyOperationHasTexts() {
        var shortTitles: [String] = []
        for operation in makeOperations() {
            #expect(operation.title.isEmpty == false)
            #expect(operation.systemImage.isEmpty == false)
            #expect(operation.helpText.isEmpty == false)
            shortTitles.append(operation.shortTitle)
        }
        #expect(shortTitles == ["Посада і компанія", "Технологія", "Рівень і формат", "Сортування за ЗП",
                                "Діапазон зарплати", "Групи спеціалізацій"])
    }

    @Test("Функції 3–6 без текстових полів завжди можна виконати")
    func operationsWithoutTextFieldsCanExecute() {
        #expect(FilterByLevelAndFormatOperation().canExecute)
        #expect(SortByAverageSalaryOperation().canExecute)
        #expect(SalaryRangeExtremesOperation().canExecute)
        #expect(GroupBySpecializationOperation().canExecute)
    }
}
