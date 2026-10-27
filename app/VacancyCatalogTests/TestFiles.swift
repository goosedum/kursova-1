//
//  TestFiles.swift
//  Допоміжні функції для тестів файлів: демо-файли з Fixtures, тимчасові файли, читання всього файлу.
//

import Foundation
import Testing
@testable import VacancyCatalog

/// Файли для `VacancyFileReaderTests` і `VacancyFileWriterTests`.
///
/// Тести запускаються всередині застосунку з пісочницею (App Sandbox), тому прочитати `samples/` напряму не можуть.
/// Папка `Fixtures` містить посилання на файли з `samples/`, а Xcode копіює їх у бандл тестів.
@MainActor
class TestFiles {

    /// Адреса демо-файлу `name.txt` з папки `Fixtures`.
    static func fixture(_ name: String) throws -> URL {
        let bundle = Bundle(for: TestFiles.self)
        return try #require(bundle.url(forResource: name, withExtension: "txt"), "Немає файлу \(name).txt у Fixtures")
    }

    /// Нова адреса в тимчасовій папці (самого файлу ще немає).
    static func temporaryURL() -> URL {
        return FileManager.default.temporaryDirectory.appending(path: "vacancies-\(UUID().uuidString).txt")
    }

    /// Створює тимчасовий файл з текстом `text` і повертає його адресу.
    static func temporaryFile(containing text: String) throws -> URL {
        let url = temporaryURL()
        try text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    /// Читає всі вакансії з файлу так, як це робитиме каталог: `>>` у буфер, у масив — копія буфера.
    static func readVacancies(from url: URL) throws -> [Vacancy] {
        let reader = try VacancyFileReader(url: url)
        let buffer = Vacancy()
        var vacancies: [Vacancy] = []
        while try reader >> buffer {
            vacancies.append(Vacancy(copyOf: buffer))
        }
        return vacancies
    }
}
