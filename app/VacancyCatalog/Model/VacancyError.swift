//
//  VacancyError.swift
//  Власні винятки програми: помилки файлу, помилки даних вакансії, порожній каталог.
//

import Foundation

/// Виняткові ситуації програми «Каталог вакансій».
///
/// Кожен випадок має повідомлення «що сталося» (`errorDescription`) і пораду «що робити» (`recoverySuggestion`) —
/// їх показує алерт. Методи, що можуть завершитися помилкою, позначені `throws`, а ViewModel перехоплює винятки
/// конструкцією `do-catch`.
enum VacancyError: LocalizedError, Equatable {

    // MARK: - Помилки файлу

    /// Файл не існує.
    case fileNotFound(path: String)
    /// Файл не вдалося прочитати (немає доступу або це не текст у UTF-8).
    case fileReadFailed(path: String)
    /// Файл не вдалося записати.
    case fileWriteFailed(path: String)
    /// У рядку файлу не 8 полів.
    case invalidFieldCount(line: Int, found: Int)
    /// Зарплата в рядку файлу не є цілим числом.
    case invalidNumber(line: Int, field: String, value: String)
    /// Невідомий рівень досвіду або формат роботи в рядку файлу.
    case unknownValue(line: Int, field: String, value: String)
    /// Дані вакансії в рядку файлу не пройшли перевірку `validate()`; `details` — текст цієї помилки.
    case invalidData(line: Int, details: String)

    // MARK: - Помилки даних вакансії

    /// Обов'язкове текстове поле порожнє.
    case emptyField(name: String)
    /// Текст поля довший за дозволений.
    case fieldTooLong(name: String, limit: Int)
    /// У полі є заборонений символ (`;` — роздільник полів у файлі, `,` — роздільник технологій).
    case forbiddenCharacter(name: String, character: String)
    /// Зарплата поза межами від 0 до 100 000 $.
    case salaryOutOfRange(value: Int)
    /// Мінімальна зарплата більша за максимальну.
    case minSalaryGreaterThanMax(min: Int, max: Int)
    /// Не вказано жодної технології.
    case noTechnologies
    /// Технологій більше, ніж дозволено.
    case tooManyTechnologies(limit: Int)

    // MARK: - Помилки функцій

    /// Функції 4–6 викликано для порожнього каталогу.
    case emptyCatalog

    // MARK: - Тексти для алерта

    /// Що сталося.
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Файл «\(path)» не знайдено."
        case .fileReadFailed(let path):
            return "Не вдалося прочитати файл «\(path)»."
        case .fileWriteFailed(let path):
            return "Не вдалося зберегти файл «\(path)»."
        case .invalidFieldCount(let line, let found):
            return "Рядок \(line): очікувалось 8 полів, знайдено \(found)."
        case .invalidNumber(let line, let field, let value):
            return "Рядок \(line): «\(value)» не є числом (\(field))."
        case .unknownValue(let line, let field, let value):
            return "Рядок \(line): невідоме значення «\(value)» (\(field))."
        case .invalidData(let line, let details):
            return "Рядок \(line): \(details)"
        case .emptyField(let name):
            return "Поле «\(name)» не може бути порожнім."
        case .fieldTooLong(let name, let limit):
            return "Поле «\(name)» задовге (максимум \(limit) символів)."
        case .forbiddenCharacter(let name, let character):
            return "Поле «\(name)» не може містити символ «\(character)»."
        case .salaryOutOfRange(let value):
            return "Зарплата має бути від 0 до 100 000 $ (зараз — \(value))."
        case .minSalaryGreaterThanMax(let min, let max):
            return "Мінімальна зарплата (\(min)) більша за максимальну (\(max))."
        case .noTechnologies:
            return "Вкажіть хоча б одну технологію."
        case .tooManyTechnologies(let limit):
            return "Забагато технологій (максимум \(limit))."
        case .emptyCatalog:
            return "Каталог порожній."
        }
    }

    /// Заголовок алерта — коротко, що не вдалося (Figma: `AlertDialog`, екрани S-15…S-17).
    var alertTitle: String {
        switch self {
        case .fileNotFound, .fileReadFailed, .invalidFieldCount, .invalidNumber, .unknownValue, .invalidData:
            return "Не вдалося відкрити файл"
        case .fileWriteFailed:
            return "Не вдалося зберегти файл"
        case .emptyField, .fieldTooLong, .forbiddenCharacter, .noTechnologies, .tooManyTechnologies:
            return "Неправильні дані вакансії"
        case .salaryOutOfRange:
            return "Неправильна зарплата"
        case .minSalaryGreaterThanMax:
            return "Неправильний діапазон зарплати"
        case .emptyCatalog:
            return "Каталог порожній"
        }
    }

    /// Текст алерта: що сталося і що робити. Для порожнього каталогу — лише порада (заголовок уже все каже).
    var alertMessage: String {
        let suggestion = recoverySuggestion ?? ""
        if self == .emptyCatalog {
            return suggestion
        }
        return (errorDescription ?? "") + " " + suggestion
    }

    /// Що зробити користувачу.
    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Перевірте, чи файл не перемістили або не перейменували."
        case .fileReadFailed:
            return "Переконайтеся, що це текстовий файл у кодуванні UTF-8."
        case .fileWriteFailed:
            return "Виберіть іншу папку або перевірте вільне місце на диску."
        case .invalidFieldCount:
            return "Поля розділяються «;»: компанія;посада;спеціалізація;рівень;мін;макс;формат;технології."
        case .invalidNumber:
            return "Зарплату вкажіть цілим числом у доларах, наприклад 1200."
        case .unknownValue:
            return "Рівень: Intern, Junior, Middle, Senior або Lead. Формат: Office, Remote або Hybrid."
        case .invalidData:
            return "Виправте рядок у файлі й відкрийте його знову. Каталог не змінено."
        case .emptyField, .fieldTooLong, .forbiddenCharacter:
            return "Виправте поле й збережіть ще раз."
        case .salaryOutOfRange, .minSalaryGreaterThanMax:
            return "Змініть зарплату: від 0 до 100 000 $, мінімальна не більша за максимальну."
        case .noTechnologies, .tooManyTechnologies:
            return "Перелічіть від 1 до 15 технологій через кому."
        case .emptyCatalog:
            return "Відкрийте файл або додайте вакансію."
        }
    }
}
