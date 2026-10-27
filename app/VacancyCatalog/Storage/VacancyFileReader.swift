//
//  VacancyFileReader.swift
//  Читання каталогу з текстового файлу оператором >> (аналог ifstream у C++).
//

import Foundation

/// Читає вакансії з текстового файлу формату `docs/analysis/02-data-model.md`, §6.
///
/// Аналог `ifstream` у C++: оператор `>>` заповнює вакансію даними наступного рядка і повертає `false`,
/// коли рядки скінчилися — як `while (fin >> vacancy)`.
/// ```swift
/// let reader = try VacancyFileReader(url: url)
/// let buffer = Vacancy()
/// while try reader >> buffer {
///     loaded.append(Vacancy(copyOf: buffer))
/// }
/// ```
/// Порожні рядки і рядки, що починаються з «#», пропускаються. На першому помилковому рядку читання
/// зупиняється винятком із номером рядка (рішення D-23).
class VacancyFileReader {

    /// Усі рядки файлу.
    private let lines: [String]
    /// Індекс рядка, який буде прочитано наступним.
    private var index = 0
    /// Номер останнього прочитаного рядка, як у текстовому редакторі (з 1, разом із коментарями).
    private(set) var currentLineNumber = 0

    /// Відкриває файл і ділить його текст на рядки.
    ///
    /// - Throws: `VacancyError.fileNotFound`, якщо файлу немає; `.fileReadFailed`, якщо це не текст у UTF-8.
    init(url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) == false {
            throw VacancyError.fileNotFound(path: url.lastPathComponent)
        }
        let text: String
        do {
            text = try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw VacancyError.fileReadFailed(path: url.lastPathComponent)
        }
        // Переноси рядків Windows (\r\n) теж підтримуються
        lines = text.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
    }

    /// Заповнює `vacancy` даними наступного рядка з вакансією.
    ///
    /// - Returns: `true`, якщо вакансію прочитано; `false`, якщо рядки скінчилися.
    /// - Throws: `VacancyError.invalidFieldCount`, `.invalidNumber`, `.unknownValue` або `.invalidData`
    ///   з номером рядка, якщо рядок помилковий.
    static func >> (reader: VacancyFileReader, vacancy: Vacancy) throws -> Bool {
        while reader.index < reader.lines.count {
            let line = reader.lines[reader.index].trimmingCharacters(in: .whitespaces)
            reader.index += 1
            reader.currentLineNumber = reader.index

            // Порожні рядки й коментарі пропускаємо
            if line.isEmpty || line.hasPrefix("#") {
                continue
            }
            try reader.parse(line, into: vacancy)
            return true
        }
        return false
    }

    /// Розбирає один рядок файлу і записує поля у `vacancy`.
    private func parse(_ line: String, into vacancy: Vacancy) throws {
        // 1. Рядок має складатися рівно з 8 полів, розділених «;»
        var fields: [String] = []
        for field in line.components(separatedBy: ";") {
            fields.append(field.trimmingCharacters(in: .whitespaces))
        }
        if fields.count != 8 {
            throw VacancyError.invalidFieldCount(line: currentLineNumber, found: fields.count)
        }

        // 2. Рівень і формат — лише з допустимих значень (англійські ключі, D-22)
        guard let level = ExperienceLevel(rawValue: fields[3]) else {
            throw VacancyError.unknownValue(line: currentLineNumber, field: "рівень досвіду", value: fields[3])
        }
        guard let format = WorkFormat(rawValue: fields[6]) else {
            throw VacancyError.unknownValue(line: currentLineNumber, field: "формат роботи", value: fields[6])
        }

        // 3. Зарплата — цілі числа
        guard let minSalary = Int(fields[4]) else {
            throw VacancyError.invalidNumber(line: currentLineNumber, field: "мінімальна зарплата", value: fields[4])
        }
        guard let maxSalary = Int(fields[5]) else {
            throw VacancyError.invalidNumber(line: currentLineNumber, field: "максимальна зарплата", value: fields[5])
        }

        // 4. Заповнюємо вакансію (технології розділені «,»)
        vacancy.company = fields[0]
        vacancy.title = fields[1]
        vacancy.specialization = fields[2]
        vacancy.experienceLevel = level
        vacancy.minSalary = minSalary
        vacancy.maxSalary = maxSalary
        vacancy.workFormat = format
        vacancy.technologies = fields[7].components(separatedBy: ",")
        vacancy.normalize()

        // 5. Ті самі правила, що й у формі; помилку доповнюємо номером рядка
        do {
            try vacancy.validate()
        } catch let error as VacancyError {
            throw VacancyError.invalidData(line: currentLineNumber, details: error.errorDescription ?? "")
        }
    }
}
