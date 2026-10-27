//
//  VacancyTests.swift
//  Тести класу Vacancy: конструктори, деструктор, обчислювані властивості, пошук технології, перевірка даних.
//

import Foundation
import Testing
@testable import VacancyCatalog

/// Тести класу `Vacancy` (T-VAC-01…07, T-ERR-01…09 з `.claude/plan/05-testing.md`).
@MainActor
struct VacancyTests {

    /// Правильна вакансія — перший рядок демо-файлу `samples/vacancies.txt`.
    private func makeVacancy() -> Vacancy {
        return Vacancy(company: "ByteForge", title: "Junior iOS Developer", specialization: "Mobile",
                       experienceLevel: .junior, minSalary: 800, maxSalary: 1200, workFormat: .office,
                       technologies: ["Swift", "UIKit", "Git"])
    }

    // MARK: - Конструктори і деструктор

    @Test("T-VAC-01: конструктор з параметрами зберігає всі 8 полів")
    func parameterizedInitStoresAllFields() {
        let vacancy = makeVacancy()
        #expect(vacancy.company == "ByteForge")
        #expect(vacancy.title == "Junior iOS Developer")
        #expect(vacancy.specialization == "Mobile")
        #expect(vacancy.experienceLevel == .junior)
        #expect(vacancy.minSalary == 800)
        #expect(vacancy.maxSalary == 1200)
        #expect(vacancy.workFormat == .office)
        #expect(vacancy.technologies == ["Swift", "UIKit", "Git"])
    }

    @Test("T-VAC-02: конструктор за замовчуванням дає «порожню» вакансію")
    func defaultInitCreatesEmptyVacancy() {
        let vacancy = Vacancy()
        #expect(vacancy.company.isEmpty)
        #expect(vacancy.title.isEmpty)
        #expect(vacancy.specialization.isEmpty)
        #expect(vacancy.experienceLevel == .junior)
        #expect(vacancy.minSalary == 0)
        #expect(vacancy.maxSalary == 0)
        #expect(vacancy.workFormat == .office)
        #expect(vacancy.technologies.isEmpty)
    }

    @Test("T-VAC-03: середня зарплата і діапазон")
    func averageSalaryAndRange() {
        let vacancy = makeVacancy()
        #expect(vacancy.averageSalary == 1000)
        #expect(vacancy.salaryRange == 400)

        vacancy.maxSalary = 1201
        #expect(vacancy.averageSalary == 1000.5)
    }

    @Test("T-VAC-04: конструктор копій копіює всі поля, але дає новий id")
    func copyInitCopiesFieldsWithNewID() {
        let original = makeVacancy()
        let copy = Vacancy(copyOf: original)
        #expect(copy !== original)
        #expect(copy.id != original.id)
        #expect(copy.company == original.company)
        #expect(copy.title == original.title)
        #expect(copy.specialization == original.specialization)
        #expect(copy.experienceLevel == original.experienceLevel)
        #expect(copy.minSalary == original.minSalary)
        #expect(copy.maxSalary == original.maxSalary)
        #expect(copy.workFormat == original.workFormat)
        #expect(copy.technologies == original.technologies)
    }

    @Test("T-VAC-05: зміна копії не змінює оригінал")
    func changingCopyKeepsOriginal() {
        let original = makeVacancy()
        let copy = Vacancy(copyOf: original)
        copy.title = "Senior iOS Developer"
        copy.technologies.append("SwiftUI")

        #expect(original.title == "Junior iOS Developer")
        #expect(original.technologies == ["Swift", "UIKit", "Git"])
    }

    @Test("T-VAC-06: об'єкт знищується (deinit), коли зникає останнє посилання")
    func deinitRunsWhenLastReferenceDisappears() {
        weak var weakVacancy: Vacancy?
        do {
            let vacancy = makeVacancy()
            weakVacancy = vacancy
            #expect(weakVacancy != nil)
        }
        // Сильних посилань більше немає — ARC знищив об'єкт, слабке посилання стало nil
        #expect(weakVacancy == nil)
    }

    @Test("T-VAC-07: пошук технології без регістру; «Swift» не плутається зі «SwiftUI»")
    func hasTechnologyIgnoresCaseButNotSubstring() {
        let vacancy = makeVacancy()
        #expect(vacancy.hasTechnology("Swift"))
        #expect(vacancy.hasTechnology("swift"))
        #expect(vacancy.hasTechnology("  GIT "))
        #expect(vacancy.hasTechnology("SwiftUI") == false)

        vacancy.technologies = ["SwiftUI", "Git"]
        #expect(vacancy.hasTechnology("Swift") == false)
    }

    // MARK: - Перевірка даних

    @Test("Правильна вакансія проходить перевірку")
    func validVacancyPasses() throws {
        try makeVacancy().validate()
    }

    @Test("T-ERR-01: порожня компанія → emptyField")
    func emptyCompanyThrows() {
        let vacancy = makeVacancy()
        vacancy.company = "   "
        #expect(throws: VacancyError.emptyField(name: "Компанія")) {
            try vacancy.validate()
        }
    }

    @Test("T-ERR-02: мінімальна зарплата більша за максимальну → minSalaryGreaterThanMax")
    func minGreaterThanMaxThrows() {
        let vacancy = makeVacancy()
        vacancy.minSalary = 5000
        vacancy.maxSalary = 3000
        #expect(throws: VacancyError.minSalaryGreaterThanMax(min: 5000, max: 3000)) {
            try vacancy.validate()
        }
    }

    @Test("T-ERR-03: зарплата поза межами 0…100 000 → salaryOutOfRange", arguments: [-1, 100_001])
    func salaryOutOfRangeThrows(salary: Int) {
        let vacancy = makeVacancy()
        vacancy.minSalary = 0
        vacancy.maxSalary = salary
        if salary < 0 {
            vacancy.minSalary = salary
        }
        #expect(throws: VacancyError.salaryOutOfRange(value: salary)) {
            try vacancy.validate()
        }
    }

    @Test("T-ERR-04: посада з 81 символу → fieldTooLong")
    func tooLongTitleThrows() {
        let vacancy = makeVacancy()
        vacancy.title = String(repeating: "a", count: 81)
        #expect(throws: VacancyError.fieldTooLong(name: "Посада", limit: 80)) {
            try vacancy.validate()
        }
    }

    @Test("T-ERR-05: символ «;» у компанії → forbiddenCharacter")
    func semicolonInCompanyThrows() {
        let vacancy = makeVacancy()
        vacancy.company = "Byte;Forge"
        #expect(throws: VacancyError.forbiddenCharacter(name: "Компанія", character: ";")) {
            try vacancy.validate()
        }
    }

    @Test("T-ERR-06: жодної технології → noTechnologies")
    func noTechnologiesThrows() {
        let vacancy = makeVacancy()
        vacancy.technologies = [" ", ""]
        #expect(throws: VacancyError.noTechnologies) {
            try vacancy.validate()
        }
    }

    @Test("T-ERR-07: мінімальна зарплата дорівнює максимальній — помилки немає")
    func equalSalariesPass() throws {
        let vacancy = makeVacancy()
        vacancy.minSalary = 1500
        vacancy.maxSalary = 1500
        try vacancy.validate()
        #expect(vacancy.salaryRange == 0)
    }

    @Test("T-ERR-08: normalize прибирає пробіли й повторні технології («Git» і «git»)")
    func normalizeTrimsAndRemovesDuplicates() {
        let vacancy = makeVacancy()
        vacancy.company = "  ByteForge "
        vacancy.technologies = [" Swift ", "Git", "git", "", "UIKit"]
        vacancy.normalize()
        #expect(vacancy.company == "ByteForge")
        #expect(vacancy.technologies == ["Swift", "Git", "UIKit"])
    }

    @Test("T-ERR-09: понад 15 технологій → tooManyTechnologies")
    func tooManyTechnologiesThrows() {
        let vacancy = makeVacancy()
        var technologies: [String] = []
        for number in 1...16 {
            technologies.append("Tech\(number)")
        }
        vacancy.technologies = technologies
        #expect(throws: VacancyError.tooManyTechnologies(limit: 15)) {
            try vacancy.validate()
        }
    }

    @Test("Вакансія з конструктора за замовчуванням не проходить перевірку")
    func defaultVacancyFailsValidation() {
        #expect(throws: VacancyError.emptyField(name: "Компанія")) {
            try Vacancy().validate()
        }
    }
}
