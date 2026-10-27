//
//  VacancyCatalogTests.swift
//  Тести каталогу: додавання, заміна, видалення, підказки, відкриття і збереження файлу.
//

import Foundation
import Testing
@testable import VacancyCatalog

/// Тести класу `VacancyCatalog` (T-CAT-17 з `.claude/plan/05-testing.md` і рішення D-23, D-25).
@MainActor
struct VacancyCatalogTests {

    /// Правильна вакансія з потрібною компанією і технологіями.
    private func makeVacancy(company: String, specialization: String = "Mobile",
                             technologies: [String] = ["Swift"]) -> Vacancy {
        return Vacancy(company: company, title: "iOS Developer", specialization: specialization,
                       experienceLevel: .middle, minSalary: 2000, maxSalary: 3000, workFormat: .remote,
                       technologies: technologies)
    }

    /// Каталог з трьох вакансій A, B, C.
    private func makeCatalog() throws -> VacancyCatalog {
        let catalog = VacancyCatalog()
        try catalog.add(makeVacancy(company: "A"))
        try catalog.add(makeVacancy(company: "B"))
        try catalog.add(makeVacancy(company: "C"))
        return catalog
    }

    // MARK: - Додавання

    @Test("Новий каталог порожній")
    func newCatalogIsEmpty() {
        #expect(VacancyCatalog().vacancies.isEmpty)
    }

    @Test("add: вакансія додається в кінець, у каталозі той самий об'єкт")
    func addAppendsSameObject() throws {
        let catalog = try makeCatalog()
        let vacancy = makeVacancy(company: "D")
        try catalog.add(vacancy)
        #expect(catalog.vacancies.count == 4)
        #expect(catalog.vacancies[3] === vacancy)
    }

    @Test("add: пробіли навколо полів прибираються (normalize)")
    func addNormalizesFields() throws {
        let catalog = VacancyCatalog()
        try catalog.add(makeVacancy(company: "  ByteForge ", technologies: [" Swift ", "swift", "Git"]))
        #expect(catalog.vacancies[0].company == "ByteForge")
        #expect(catalog.vacancies[0].technologies == ["Swift", "Git"])
    }

    @Test("add: неправильна вакансія → виняток, каталог не змінився")
    func addInvalidThrowsAndKeepsCatalog() throws {
        let catalog = try makeCatalog()
        let invalid = makeVacancy(company: "D")
        invalid.minSalary = 5000
        invalid.maxSalary = 3000
        #expect(throws: VacancyError.minSalaryGreaterThanMax(min: 5000, max: 3000)) {
            try catalog.add(invalid)
        }
        #expect(catalog.vacancies.count == 3)
    }

    // MARK: - Заміна (редагування через копію)

    @Test("replace: копія з правками стає на місце оригіналу, оригінал не змінився")
    func replacePutsEditedCopyInPlace() throws {
        let catalog = try makeCatalog()
        let original = catalog.vacancies[1]
        let edited = Vacancy(copyOf: original)
        edited.title = "Senior iOS Developer"

        try catalog.replace(original, with: edited)
        #expect(catalog.vacancies.count == 3)
        #expect(catalog.vacancies[1] === edited)
        #expect(catalog.vacancies[0].company == "A")
        #expect(catalog.vacancies[2].company == "C")
        #expect(original.title == "iOS Developer")
    }

    @Test("replace: неправильні дані → виняток, на місці лишився оригінал")
    func replaceInvalidThrowsAndKeepsOriginal() throws {
        let catalog = try makeCatalog()
        let original = catalog.vacancies[1]
        let edited = Vacancy(copyOf: original)
        edited.company = ""

        #expect(throws: VacancyError.emptyField(name: "Компанія")) {
            try catalog.replace(original, with: edited)
        }
        #expect(catalog.vacancies[1] === original)
    }

    // MARK: - Видалення

    @Test("remove: одна вакансія; вакансія не з каталогу нічого не змінює")
    func removeOne() throws {
        let catalog = try makeCatalog()
        catalog.remove(catalog.vacancies[0])
        #expect(catalog.vacancies.count == 2)
        #expect(catalog.vacancies[0].company == "B")

        // Інший об'єкт з такими самими полями — це не вакансія з каталогу
        catalog.remove(makeVacancy(company: "B"))
        #expect(catalog.vacancies.count == 2)
    }

    @Test("remove: кілька вибраних (D-25) і removeAll")
    func removeSeveralAndAll() throws {
        let catalog = try makeCatalog()
        let selected = [catalog.vacancies[0], catalog.vacancies[2]]
        for vacancy in selected {
            catalog.remove(vacancy)
        }
        #expect(catalog.vacancies.count == 1)
        #expect(catalog.vacancies[0].company == "B")

        catalog.removeAll()
        #expect(catalog.vacancies.isEmpty)
    }

    // MARK: - Підказки

    @Test("allTechnologies: без повторів (регістр не важливий) і за абеткою")
    func allTechnologiesAreUniqueAndSorted() throws {
        let catalog = VacancyCatalog()
        try catalog.add(makeVacancy(company: "A", technologies: ["Swift", "Git"]))
        try catalog.add(makeVacancy(company: "B", technologies: ["git", "Docker"]))
        try catalog.add(makeVacancy(company: "C", technologies: ["swift", "Kotlin", "AWS"]))
        #expect(catalog.allTechnologies == ["AWS", "Docker", "Git", "Kotlin", "Swift"])
    }

    @Test("allSpecializations: без повторів і за абеткою")
    func allSpecializationsAreUniqueAndSorted() throws {
        let catalog = VacancyCatalog()
        try catalog.add(makeVacancy(company: "A", specialization: "Mobile"))
        try catalog.add(makeVacancy(company: "B", specialization: "Backend"))
        try catalog.add(makeVacancy(company: "C", specialization: "mobile"))
        #expect(catalog.allSpecializations == ["Backend", "Mobile"])
    }

    // MARK: - Файли

    @Test("load: демо-файл — 28 вакансій")
    func loadDemoFile() throws {
        let catalog = VacancyCatalog()
        try catalog.load(from: TestFiles.fixture("vacancies"))
        #expect(catalog.vacancies.count == 28)
        #expect(catalog.vacancies[0].company == "ByteForge")
    }

    @Test("load: файл замінює старий вміст каталогу")
    func loadReplacesOldContent() throws {
        let catalog = try makeCatalog()
        try catalog.load(from: TestFiles.fixture("vacancies"))
        #expect(catalog.vacancies.count == 28)

        try catalog.load(from: TestFiles.fixture("empty"))
        #expect(catalog.vacancies.isEmpty)
    }

    @Test("load: помилка в рядку файлу → виняток, каталог не змінився (D-23)",
          arguments: ["broken-field-count", "broken-salary", "broken-level", "broken-min-max"])
    func loadBrokenFileKeepsCatalog(name: String) throws {
        let catalog = try makeCatalog()
        let first = catalog.vacancies[0]
        let url = try TestFiles.fixture(name)

        #expect(throws: VacancyError.self) {
            try catalog.load(from: url)
        }
        #expect(catalog.vacancies.count == 3)
        #expect(catalog.vacancies[0] === first)
    }

    @Test("load: неіснуючий файл → fileNotFound, каталог не змінився")
    func loadMissingFileKeepsCatalog() throws {
        let catalog = try makeCatalog()
        let url = FileManager.default.temporaryDirectory.appending(path: "no-such-file.txt")
        #expect(throws: VacancyError.fileNotFound(path: "no-such-file.txt")) {
            try catalog.load(from: url)
        }
        #expect(catalog.vacancies.count == 3)
    }

    @Test("save → load: зберегли каталог і відкрили — ті самі дані в тому самому порядку")
    func saveThenLoadGivesSameCatalog() throws {
        let original = VacancyCatalog()
        try original.load(from: TestFiles.fixture("vacancies"))
        let url = TestFiles.temporaryURL()
        try original.save(to: url)

        let reopened = VacancyCatalog()
        try reopened.load(from: url)
        #expect(reopened.vacancies.count == original.vacancies.count)
        for index in 0..<original.vacancies.count {
            let before = original.vacancies[index]
            let after = reopened.vacancies[index]
            #expect(after.company == before.company)
            #expect(after.title == before.title)
            #expect(after.specialization == before.specialization)
            #expect(after.experienceLevel == before.experienceLevel)
            #expect(after.minSalary == before.minSalary)
            #expect(after.maxSalary == before.maxSalary)
            #expect(after.workFormat == before.workFormat)
            #expect(after.technologies == before.technologies)
        }
    }

    @Test("save: порожній каталог зберігається (лише заголовок) і відкривається як порожній")
    func saveEmptyCatalog() throws {
        let url = TestFiles.temporaryURL()
        try VacancyCatalog().save(to: url)

        let reopened = try makeCatalog()
        try reopened.load(from: url)
        #expect(reopened.vacancies.isEmpty)
    }

    @Test("save: запис у неіснуючу папку → fileWriteFailed")
    func saveToMissingFolderThrows() throws {
        let catalog = try makeCatalog()
        let folder = FileManager.default.temporaryDirectory.appending(path: "no-such-folder-\(UUID().uuidString)")
        #expect(throws: VacancyError.fileWriteFailed(path: "catalog.txt")) {
            try catalog.save(to: folder.appending(path: "catalog.txt"))
        }
    }
}
