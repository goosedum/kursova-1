//
//  TextFormatTests.swift
//  Тести українських текстів з числами: форми слова «вакансія» і суми в доларах.
//

import Testing
@testable import VacancyCatalog

/// Тести `TextFormat`.
@MainActor
struct TextFormatTests {

    @Test("Форма слова після числа: 1 вакансія, 2 вакансії, 5 вакансій, 11–14 вакансій",
          arguments: [(0, "0 вакансій"), (1, "1 вакансія"), (2, "2 вакансії"), (4, "4 вакансії"), (5, "5 вакансій"),
                      (11, "11 вакансій"), (12, "12 вакансій"), (14, "14 вакансій"), (21, "21 вакансія"),
                      (22, "22 вакансії"), (28, "28 вакансій"), (111, "111 вакансій"), (101, "101 вакансія")])
    func vacancyWordForms(number: Int, expected: String) {
        #expect(TextFormat.vacancies(number) == expected)
    }

    @Test("Інші слова: групи")
    func otherWords() {
        #expect(TextFormat.count(1, one: "група", few: "групи", many: "груп") == "1 група")
        #expect(TextFormat.count(3, one: "група", few: "групи", many: "груп") == "3 групи")
        #expect(TextFormat.count(8, one: "група", few: "групи", many: "груп") == "8 груп")
    }

    @Test("Суми з пробілом між тисячами",
          arguments: [(0, "$0"), (300, "$300"), (3000, "$3 000"), (12500, "$12 500"), (100_000, "$100 000")])
    func money(amount: Int, expected: String) {
        #expect(TextFormat.money(amount) == expected)
    }

    @Test("Середня зарплата: ціла — без десятих, з половиною — «,5»",
          arguments: [(1000.0, "$1 000"), (1000.5, "$1 000,5"), (550.0, "$550"), (6250.0, "$6 250")])
    func moneyWithTenths(amount: Double, expected: String) {
        #expect(TextFormat.money(amount) == expected)
    }
}
