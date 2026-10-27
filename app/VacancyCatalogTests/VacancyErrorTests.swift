//
//  VacancyErrorTests.swift
//  Тести переліку VacancyError: тексти повідомлень і порад для алерта.
//

import Testing
@testable import VacancyCatalog

/// Тести переліку `VacancyError`.
@MainActor
struct VacancyErrorTests {

    @Test("Повідомлення містять конкретні значення")
    func descriptionsContainValues() {
        #expect(VacancyError.minSalaryGreaterThanMax(min: 5000, max: 3000).errorDescription
                == "Мінімальна зарплата (5000) більша за максимальну (3000).")
        #expect(VacancyError.emptyField(name: "Компанія").errorDescription
                == "Поле «Компанія» не може бути порожнім.")
        #expect(VacancyError.invalidFieldCount(line: 5, found: 6).errorDescription
                == "Рядок 5: очікувалось 8 полів, знайдено 6.")
    }

    @Test("Помилка рядка файлу містить номер рядка і текст помилки даних")
    func invalidDataContainsLine() {
        let details = VacancyError.emptyField(name: "Компанія").errorDescription ?? ""
        #expect(VacancyError.invalidData(line: 6, details: details).errorDescription
                == "Рядок 6: Поле «Компанія» не може бути порожнім.")
    }

    @Test("Для кожної помилки є порада, що робити")
    func everyErrorHasRecoverySuggestion() {
        let errors: [VacancyError] = [
            .fileNotFound(path: "a.txt"), .fileReadFailed(path: "a.txt"), .fileWriteFailed(path: "a.txt"),
            .invalidFieldCount(line: 1, found: 7), .invalidNumber(line: 1, field: "мін. зарплата", value: "abc"),
            .unknownValue(line: 1, field: "рівень", value: "Pro"), .invalidData(line: 1, details: "…"),
            .emptyField(name: "Посада"), .fieldTooLong(name: "Посада", limit: 80),
            .forbiddenCharacter(name: "Посада", character: ";"), .salaryOutOfRange(value: -1),
            .minSalaryGreaterThanMax(min: 2, max: 1), .noTechnologies, .tooManyTechnologies(limit: 15), .emptyCatalog
        ]
        for error in errors {
            #expect(error.errorDescription?.isEmpty == false)
            #expect(error.recoverySuggestion?.isEmpty == false)
        }
    }
}
