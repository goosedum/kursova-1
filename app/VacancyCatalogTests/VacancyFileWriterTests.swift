//
//  VacancyFileWriterTests.swift
//  Тести запису у файл оператором <<: формат рядка, round-trip, помилка запису.
//

import Foundation
import Testing
@testable import VacancyCatalog

/// Тести класу `VacancyFileWriter` (T-IO-01, T-IO-02 з `.claude/plan/05-testing.md`).
@MainActor
struct VacancyFileWriterTests {

    /// Три різні вакансії: усі рівні полів, кирилиця (перевірка UTF-8), кілька технологій.
    private func makeVacancies() -> [Vacancy] {
        return [
            Vacancy(company: "ByteForge", title: "Junior iOS Developer", specialization: "Mobile",
                    experienceLevel: .junior, minSalary: 800, maxSalary: 1200, workFormat: .office,
                    technologies: ["Swift", "UIKit", "Git"]),
            Vacancy(company: "Львів Софт", title: "Senior Backend Developer", specialization: "Backend",
                    experienceLevel: .senior, minSalary: 4000, maxSalary: 6000, workFormat: .remote,
                    technologies: ["Go", "PostgreSQL"]),
            Vacancy(company: "DataWave", title: "Data Science Intern", specialization: "Data Science",
                    experienceLevel: .intern, minSalary: 0, maxSalary: 500, workFormat: .hybrid,
                    technologies: ["Python"])
        ]
    }

    @Test("Рядок файлу: 8 полів через «;», технології через «,», заголовок-коментар")
    func savedFileHasExpectedFormat() throws {
        let url = TestFiles.temporaryURL()
        let writer = VacancyFileWriter(url: url)
        writer << makeVacancies()[0]
        try writer.save()

        let text = try String(contentsOf: url, encoding: .utf8)
        #expect(text == """
            # Каталог вакансій для ІТ-спеціалістів
            # компанія;посада;спеціалізація;рівень;мін;макс;формат;технології
            ByteForge;Junior iOS Developer;Mobile;Junior;800;1200;Office;Swift,UIKit,Git

            """)
    }

    @Test("T-IO-01: записали << і прочитали >> — усі поля однакові (round-trip)")
    func writeThenReadGivesSameVacancies() throws {
        let url = TestFiles.temporaryURL()
        let original = makeVacancies()
        let writer = VacancyFileWriter(url: url)
        for vacancy in original {
            writer << vacancy
        }
        try writer.save()

        let loaded = try TestFiles.readVacancies(from: url)
        #expect(loaded.count == original.count)
        for index in 0..<loaded.count {
            #expect(loaded[index].company == original[index].company)
            #expect(loaded[index].title == original[index].title)
            #expect(loaded[index].specialization == original[index].specialization)
            #expect(loaded[index].experienceLevel == original[index].experienceLevel)
            #expect(loaded[index].minSalary == original[index].minSalary)
            #expect(loaded[index].maxSalary == original[index].maxSalary)
            #expect(loaded[index].workFormat == original[index].workFormat)
            #expect(loaded[index].technologies == original[index].technologies)
        }
    }

    @Test("T-IO-02: << повертає той самий writer, тому можна продовжити: (writer << a) << b")
    func shiftOperatorReturnsSameWriter() throws {
        let url = TestFiles.temporaryURL()
        let vacancies = makeVacancies()
        let writer = VacancyFileWriter(url: url)

        // У Swift оператор << неасоціативний: без дужок `writer << a << b` не компілюється
        let result = (writer << vacancies[0]) << vacancies[1]
        #expect(result === writer)

        try writer.save()
        let loaded = try TestFiles.readVacancies(from: url)
        #expect(loaded.count == 2)
        #expect(loaded[1].company == "Львів Софт")
    }

    @Test("Повторне збереження замінює старий вміст файлу")
    func saveReplacesOldContent() throws {
        let url = try TestFiles.temporaryFile(containing: "старий текст\n")
        let writer = VacancyFileWriter(url: url)
        writer << makeVacancies()[2]
        try writer.save()

        let loaded = try TestFiles.readVacancies(from: url)
        #expect(loaded.count == 1)
        #expect(loaded[0].title == "Data Science Intern")
    }

    @Test("Запис у неіснуючу папку → fileWriteFailed")
    func saveToMissingFolderThrows() {
        let folder = FileManager.default.temporaryDirectory.appending(path: "no-such-folder-\(UUID().uuidString)")
        let writer = VacancyFileWriter(url: folder.appending(path: "catalog.txt"))
        writer << makeVacancies()[0]
        #expect(throws: VacancyError.fileWriteFailed(path: "catalog.txt")) {
            try writer.save()
        }
    }
}
