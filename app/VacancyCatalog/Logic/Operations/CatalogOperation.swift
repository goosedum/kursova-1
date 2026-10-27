//
//  CatalogOperation.swift
//  Базовий клас функцій 1–6: назва, іконка, підказка і метод execute, який перевизначають підкласи.
//

import Foundation

/// Базовий клас для функцій аналізу каталогу (рішення D-14).
///
/// Кожна з шести функцій — підклас, який перевизначає `execute(on:)`. Головне вікно тримає масив
/// `[CatalogOperation]` і викликає `execute` однаково для всіх — спрацьовує метод конкретного підкласу
/// (поліморфізм, як віртуальна функція в C++).
///
/// У Swift немає ключового слова `abstract`, тому «абстрактність» зроблено так: базовий `execute` зупиняє програму
/// з повідомленням, що метод треба перевизначити (аналог чистої віртуальної функції `= 0`).
class CatalogOperation {

    /// Повна назва: заголовок панелі над таблицею і пункт меню «Аналіз».
    let title: String
    /// Коротка назва для сайдбару.
    let shortTitle: String
    /// Назва іконки SF Symbols (`docs/design/icons.md`).
    let systemImage: String
    /// Пояснення під заголовком панелі: як саме працює функція.
    let helpText: String

    /// Викликається з конструкторів підкласів: `super.init(title: …)`.
    init(title: String, shortTitle: String, systemImage: String, helpText: String) {
        self.title = title
        self.shortTitle = shortTitle
        self.systemImage = systemImage
        self.helpText = helpText
    }

    /// Чи заповнені параметри так, що функцію можна виконати (кнопка «Виконати» активна).
    ///
    /// За замовчуванням — так; підкласи з текстовими полями перевизначають цю властивість.
    var canExecute: Bool {
        return true
    }

    /// Виконує функцію над каталогом. Каталог не змінюється — результат містить посилання на його вакансії.
    ///
    /// Кожен підклас обов'язково перевизначає цей метод.
    /// - Throws: `VacancyError.emptyCatalog`, якщо функції потрібні дані, а каталог порожній (ф.4–6).
    func execute(on catalog: VacancyCatalog) throws -> OperationResult {
        fatalError("execute(on:) треба перевизначити в підкласі \(type(of: self))")
    }

    // MARK: - Спільні допоміжні методи для підкласів

    /// Кидає `VacancyError.emptyCatalog`, якщо в каталозі немає жодної вакансії.
    func checkNotEmpty(_ catalog: VacancyCatalog) throws {
        if catalog.vacancies.isEmpty {
            throw VacancyError.emptyCatalog
        }
    }

    /// Результат пошуку (ф.1–3): одна група без заголовка і підсумок «Знайдено N вакансій» або «Нічого не знайдено».
    func searchResult(title: String, found: [Vacancy]) -> OperationResult {
        var summary = "Нічого не знайдено"
        if found.isEmpty == false {
            // «Знайдено 1 вакансію» — після «знайдено» знахідний відмінок
            summary = "Знайдено " + TextFormat.count(found.count, one: "вакансію", few: "вакансії", many: "вакансій")
        }
        return OperationResult(title: title, summary: summary, groups: [VacancyGroup(title: "", vacancies: found)])
    }
}
