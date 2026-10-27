//
//  VacancyFileReaderTests.swift
//  Тести читання з файлу оператором >>: демо-файли з samples/, коментарі, помилки з номером рядка.
//

import Foundation
import Testing
@testable import VacancyCatalog

/// Тести класу `VacancyFileReader` (T-IO-03…08 з `.claude/plan/05-testing.md`).
@MainActor
struct VacancyFileReaderTests {

    // MARK: - Правильні файли

    @Test("Демо-файл vacancies.txt: 28 вакансій, перша — ByteForge")
    func readsDemoFile() throws {
        let vacancies = try TestFiles.readVacancies(from: TestFiles.fixture("vacancies"))
        #expect(vacancies.count == 28)

        let first = vacancies[0]
        #expect(first.company == "ByteForge")
        #expect(first.title == "Junior iOS Developer")
        #expect(first.specialization == "Mobile")
        #expect(first.experienceLevel == .junior)
        #expect(first.minSalary == 800)
        #expect(first.maxSalary == 1200)
        #expect(first.workFormat == .office)
        #expect(first.technologies == ["Swift", "UIKit", "Git"])
    }

    @Test("Порожній файл empty.txt — 0 вакансій, без помилки")
    func emptyFileGivesNoVacancies() throws {
        let vacancies = try TestFiles.readVacancies(from: TestFiles.fixture("empty"))
        #expect(vacancies.isEmpty)
    }

    @Test("T-IO-03: порожні рядки і «#»-коментарі пропускаються")
    func skipsEmptyLinesAndComments() throws {
        let url = try TestFiles.temporaryFile(containing: """
            # коментар

            ByteForge;Junior iOS Developer;Mobile;Junior;800;1200;Office;Swift,UIKit,Git

              # коментар з відступом
            CodeNest;Middle Backend Developer;Backend;Middle;2000;3000;Remote;Java,Spring
            """)
        let reader = try VacancyFileReader(url: url)
        let buffer = Vacancy()

        #expect(try reader >> buffer)
        #expect(buffer.company == "ByteForge")
        #expect(reader.currentLineNumber == 3)

        #expect(try reader >> buffer)
        #expect(buffer.company == "CodeNest")
        #expect(reader.currentLineNumber == 6)

        #expect(try reader >> buffer == false)
    }

    @Test("Переноси рядків Windows (\\r\\n) теж читаються")
    func readsWindowsLineEndings() throws {
        let url = try TestFiles.temporaryFile(containing:
            "# коментар\r\nByteForge;Junior iOS Developer;Mobile;Junior;800;1200;Office;Swift,Git\r\n")
        let vacancies = try TestFiles.readVacancies(from: url)
        #expect(vacancies.count == 1)
        #expect(vacancies[0].technologies == ["Swift", "Git"])
    }

    @Test("T-IO-08: пробіли навколо «;» і «,» обрізаються, повтори технологій прибираються")
    func trimsSpacesAroundSeparators() throws {
        let url = try TestFiles.temporaryFile(containing:
            " ByteForge ; Junior iOS Developer ;Mobile; Junior ; 800 ;1200; Office ; Swift , UIKit ,Git, swift \n")
        let vacancies = try TestFiles.readVacancies(from: url)
        #expect(vacancies.count == 1)
        #expect(vacancies[0].company == "ByteForge")
        #expect(vacancies[0].title == "Junior iOS Developer")
        #expect(vacancies[0].minSalary == 800)
        #expect(vacancies[0].technologies == ["Swift", "UIKit", "Git"])
    }

    // MARK: - Помилки у файлі (демо-файли samples/broken-*.txt)

    @Test("T-IO-04: 7 полів у рядку 5 → invalidFieldCount; перші вакансії вже прочитані")
    func wrongFieldCountThrowsWithLineNumber() throws {
        let reader = try VacancyFileReader(url: TestFiles.fixture("broken-field-count"))
        let buffer = Vacancy()
        var readCount = 0
        #expect(throws: VacancyError.invalidFieldCount(line: 5, found: 7)) {
            while try reader >> buffer {
                readCount += 1
            }
        }
        // Читання зупинилося на помилковому рядку: каталог має відкинути ці 2 вакансії (D-23)
        #expect(readCount == 2)
    }

    @Test("T-IO-05: «abc» замість зарплати в рядку 6 → invalidNumber")
    func notNumberThrows() throws {
        let url = try TestFiles.fixture("broken-salary")
        #expect(throws: VacancyError.invalidNumber(line: 6, field: "мінімальна зарплата", value: "abc")) {
            try TestFiles.readVacancies(from: url)
        }
    }

    @Test("T-IO-06: невідомий рівень «Pro» у рядку 7 → unknownValue")
    func unknownLevelThrows() throws {
        let url = try TestFiles.fixture("broken-level")
        #expect(throws: VacancyError.unknownValue(line: 7, field: "рівень досвіду", value: "Pro")) {
            try TestFiles.readVacancies(from: url)
        }
    }

    @Test("T-IO-06: невідомий формат роботи «Online» → unknownValue")
    func unknownFormatThrows() throws {
        let url = try TestFiles.temporaryFile(containing:
            "ByteForge;Junior iOS Developer;Mobile;Junior;800;1200;Online;Swift\n")
        #expect(throws: VacancyError.unknownValue(line: 1, field: "формат роботи", value: "Online")) {
            try TestFiles.readVacancies(from: url)
        }
    }

    @Test("Мінімальна зарплата більша за максимальну в рядку 4 → invalidData з поясненням")
    func invalidDataThrowsWithLineNumber() throws {
        let url = try TestFiles.fixture("broken-min-max")
        let details = "Мінімальна зарплата (5000) більша за максимальну (3000)."
        #expect(throws: VacancyError.invalidData(line: 4, details: details)) {
            try TestFiles.readVacancies(from: url)
        }
    }

    // MARK: - Помилки відкриття файлу

    @Test("T-IO-07: неіснуючий файл → fileNotFound")
    func missingFileThrows() {
        let url = FileManager.default.temporaryDirectory.appending(path: "no-such-file.txt")
        #expect(throws: VacancyError.fileNotFound(path: "no-such-file.txt")) {
            try VacancyFileReader(url: url)
        }
    }

    @Test("Файл не в кодуванні UTF-8 → fileReadFailed")
    func notUTF8FileThrows() throws {
        let url = TestFiles.temporaryURL()
        // 0xFF не може бути в тексті UTF-8
        try Data([0x41, 0xFF, 0xFE, 0x42]).write(to: url)
        #expect(throws: VacancyError.fileReadFailed(path: url.lastPathComponent)) {
            try VacancyFileReader(url: url)
        }
    }
}
