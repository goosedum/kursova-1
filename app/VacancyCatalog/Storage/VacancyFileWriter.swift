//
//  VacancyFileWriter.swift
//  Запис каталогу в текстовий файл оператором << (аналог ofstream у C++).
//

import Foundation

/// Записує вакансії в текстовий файл формату `docs/analysis/02-data-model.md`, §6.
///
/// Аналог `ofstream` у C++: оператор `<<` додає вакансію в буфер, метод `save()` записує буфер у файл.
/// ```swift
/// let writer = VacancyFileWriter(url: url)
/// for vacancy in catalog.vacancies {
///     writer << vacancy
/// }
/// try writer.save()
/// ```
/// На відміну від C++, у Swift оператор `<<` неасоціативний, тому ланцюжок `writer << a << b` не компілюється —
/// пишемо цикл або дужки: `(writer << a) << b`.
class VacancyFileWriter {

    /// Файл, у який буде записано каталог.
    private let url: URL
    /// Рядки майбутнього файлу: спершу коментар-заголовок, потім по рядку на вакансію.
    private var buffer: [String]

    /// Створює «потік» запису у файл `url`. Сам файл з'явиться лише після `save()`.
    init(url: URL) {
        self.url = url
        buffer = [
            "# Каталог вакансій для ІТ-спеціалістів",
            "# компанія;посада;спеціалізація;рівень;мін;макс;формат;технології"
        ]
    }

    /// Додає вакансію в буфер одним рядком: 8 полів через «;», технології через «,».
    ///
    /// - Returns: Той самий `writer`, як `ostream&` у C++ (у дужках можна продовжити: `(writer << a) << b`).
    @discardableResult
    static func << (writer: VacancyFileWriter, vacancy: Vacancy) -> VacancyFileWriter {
        let fields: [String] = [
            vacancy.company,
            vacancy.title,
            vacancy.specialization,
            vacancy.experienceLevel.rawValue,
            String(vacancy.minSalary),
            String(vacancy.maxSalary),
            vacancy.workFormat.rawValue,
            vacancy.technologies.joined(separator: ",")
        ]
        writer.buffer.append(fields.joined(separator: ";"))
        return writer
    }

    /// Записує буфер у файл у кодуванні UTF-8 (старий вміст файлу замінюється).
    ///
    /// - Throws: `VacancyError.fileWriteFailed`, якщо файл не вдалося записати.
    func save() throws {
        let text = buffer.joined(separator: "\n") + "\n"
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw VacancyError.fileWriteFailed(path: url.lastPathComponent)
        }
    }
}
