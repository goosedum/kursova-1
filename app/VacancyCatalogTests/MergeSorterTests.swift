//
//  MergeSorterTests.swift
//  Тести сортування злиттям: крайні випадки, дублікати, стабільність, порівняння з sorted(by:).
//

import Testing
@testable import VacancyCatalog

/// Тести класу `MergeSorter<Element>` (T-SORT-01…06 з `.claude/plan/05-testing.md`).
@MainActor
struct MergeSorterTests {

    /// Сортує цілі числа за зростанням.
    private func sortAscending(_ numbers: [Int]) -> [Int] {
        let sorter = MergeSorter<Int>()
        return sorter.sort(numbers, by: { first, second in
            return first < second
        })
    }

    /// Вакансія, у якої важлива лише зарплата (середня = (min + max) / 2).
    private func makeVacancy(company: String, minSalary: Int, maxSalary: Int) -> Vacancy {
        return Vacancy(company: company, title: "Developer", specialization: "Backend", experienceLevel: .middle,
                       minSalary: minSalary, maxSalary: maxSalary, workFormat: .remote, technologies: ["Swift"])
    }

    @Test("T-SORT-01: порожній масив лишається порожнім")
    func emptyArray() {
        #expect(sortAscending([]) == [])
    }

    @Test("T-SORT-02: масив з одного елемента не змінюється")
    func singleElement() {
        #expect(sortAscending([42]) == [42])
    }

    @Test("T-SORT-03: уже відсортований і обернений масиви")
    func sortedAndReversed() {
        #expect(sortAscending([1, 2, 3, 4, 5, 6]) == [1, 2, 3, 4, 5, 6])
        #expect(sortAscending([6, 5, 4, 3, 2, 1]) == [1, 2, 3, 4, 5, 6])
    }

    @Test("Приклад зі звіту: 6 чисел (парна кількість) і 7 чисел (непарна)")
    func reportExample() {
        #expect(sortAscending([38, 27, 43, 3, 9, 82]) == [3, 9, 27, 38, 43, 82])
        #expect(sortAscending([38, 27, 43, 3, 9, 82, 10]) == [3, 9, 10, 27, 38, 43, 82])
    }

    @Test("T-SORT-04: дублікати і від'ємні числа")
    func duplicates() {
        #expect(sortAscending([3, 1, 3, 2, 1, 3]) == [1, 1, 2, 3, 3, 3])
        #expect(sortAscending([0, -5, 7, -5, 0]) == [-5, -5, 0, 0, 7])
    }

    @Test("Порядок задає замикання: спадання для чисел, абетка для рядків (generic)")
    func orderComesFromClosure() {
        let numberSorter = MergeSorter<Int>()
        let descending = numberSorter.sort([2, 9, 4, 7], by: { first, second in
            return first > second
        })
        #expect(descending == [9, 7, 4, 2])

        let stringSorter = MergeSorter<String>()
        let alphabetical = stringSorter.sort(["Middle", "Intern", "Senior", "Junior"], by: { first, second in
            return first < second
        })
        #expect(alphabetical == ["Intern", "Junior", "Middle", "Senior"])
    }

    @Test("T-SORT-05: стабільність — вакансії з однаковою середньою ЗП зберігають вихідний порядок")
    func stableForEqualKeys() {
        // A і C мають однакову середню зарплату 1000, але різні діапазони
        let vacancyA = makeVacancy(company: "A", minSalary: 800, maxSalary: 1200)
        let vacancyB = makeVacancy(company: "B", minSalary: 2000, maxSalary: 3000)
        let vacancyC = makeVacancy(company: "C", minSalary: 900, maxSalary: 1100)
        let vacancyD = makeVacancy(company: "D", minSalary: 300, maxSalary: 500)
        let vacancies = [vacancyA, vacancyB, vacancyC, vacancyD]
        let sorter = MergeSorter<Vacancy>()

        // За спаданням (↓): B (2500), A (1000), C (1000), D (400) — A лишилась перед C
        let descending = sorter.sort(vacancies, by: { first, second in
            return first.averageSalary > second.averageSalary
        })
        #expect(descending[0] === vacancyB)
        #expect(descending[1] === vacancyA)
        #expect(descending[2] === vacancyC)
        #expect(descending[3] === vacancyD)

        // За зростанням (↑): D, A, C, B — і тут A перед C
        let ascending = sorter.sort(vacancies, by: { first, second in
            return first.averageSalary < second.averageSalary
        })
        #expect(ascending[0] === vacancyD)
        #expect(ascending[1] === vacancyA)
        #expect(ascending[2] === vacancyC)
        #expect(ascending[3] === vacancyB)

        // Вихідний масив не змінився
        #expect(vacancies[0] === vacancyA)
        #expect(vacancies[3] === vacancyD)
    }

    @Test("T-SORT-06: результат збігається з sorted(by:) на 200 випадкових числах")
    func matchesStandardSort() {
        var numbers: [Int] = []
        for _ in 1...200 {
            numbers.append(Int.random(in: -1000...1000))
        }
        let expected = numbers.sorted(by: { first, second in
            return first < second
        })
        #expect(sortAscending(numbers) == expected)
    }
}
