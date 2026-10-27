//
//  VacancyCatalog.swift
//  Каталог вакансій: сховище з перевіркою даних, читання з файлу і запис у файл.
//

import Foundation
import Observation

/// Каталог вакансій — масив об'єктів `Vacancy` і дії над ним.
///
/// Каталог лише зберігає вакансії й не пропускає неправильних даних: перед додаванням кожна вакансія
/// проходить `validate()`. Функцій 1–6 тут немає — вони в класах операцій `CatalogOperation` (рішення D-14).
/// Масив можна змінити тільки методами каталогу (`private(set)`) — це інкапсуляція.
/// `@Observable` — таблиця і рядок стану оновлюються самі, коли змінюється масив.
@Observable
class VacancyCatalog {

    /// Усі вакансії в порядку додавання (або в порядку рядків файлу).
    private(set) var vacancies: [Vacancy] = []

    /// Усі різні технології з усіх вакансій за абеткою — підказки для пошуку за технологією (ф.2).
    ///
    /// «Swift» і «swift» вважаються однією технологією; лишається написання, яке трапилося першим.
    var allTechnologies: [String] {
        var names: [String] = []
        for vacancy in vacancies {
            for technology in vacancy.technologies {
                names.append(technology)
            }
        }
        return uniqueSorted(names)
    }

    /// Усі різні спеціалізації за абеткою (без урахування регістру) — підказки у формі вакансії.
    var allSpecializations: [String] {
        var names: [String] = []
        for vacancy in vacancies {
            names.append(vacancy.specialization)
        }
        return uniqueSorted(names)
    }

    // MARK: - Зміна каталогу

    /// Додає вакансію в кінець каталогу.
    ///
    /// - Throws: `VacancyError` з `validate()`, якщо дані неправильні; тоді каталог не змінюється.
    func add(_ vacancy: Vacancy) throws {
        try vacancy.validate()
        vacancy.normalize()
        vacancies.append(vacancy)
    }

    /// Вставляє вакансію одразу після `other` (дублювання, UC-09). Якщо `other` у каталозі немає — у кінець.
    ///
    /// - Throws: `VacancyError` з `validate()`, якщо дані неправильні; тоді каталог не змінюється.
    func insert(_ vacancy: Vacancy, after other: Vacancy) throws {
        try vacancy.validate()
        vacancy.normalize()
        if let position = position(of: other) {
            vacancies.insert(vacancy, at: position + 1)
        } else {
            vacancies.append(vacancy)
        }
    }

    /// Ставить відредаговану вакансію `new` на місце `old` (порядок рядків не змінюється).
    ///
    /// Форма редагує копію (`Vacancy(copyOf:)`), тому старий об'єкт лишається незмінним, доки дані не перевірено.
    /// Якщо `old` у каталозі немає, нічого не відбувається.
    /// - Throws: `VacancyError` з `validate()`, якщо дані `new` неправильні; тоді каталог не змінюється.
    func replace(_ old: Vacancy, with new: Vacancy) throws {
        try new.validate()
        new.normalize()
        if let position = position(of: old) {
            vacancies[position] = new
        }
    }

    /// Видаляє вакансію з каталогу. Якщо її в каталозі немає, нічого не відбувається.
    func remove(_ vacancy: Vacancy) {
        if let position = position(of: vacancy) {
            vacancies.remove(at: position)
        }
    }

    /// Видаляє всі вакансії (новий порожній каталог).
    func removeAll() {
        vacancies.removeAll()
    }

    // MARK: - Файли

    /// Замінює вміст каталогу вакансіями з файлу (оператор `>>`).
    ///
    /// Вакансії спершу читаються в тимчасовий масив; `vacancies` замінюється тільки тоді, коли весь файл
    /// прочитано без помилок. Якщо в рядку помилка, каталог лишається таким, як був (рішення D-23).
    /// - Throws: `VacancyError` з `VacancyFileReader` (файл не знайдено, помилка в рядку N тощо).
    func load(from url: URL) throws {
        let reader = try VacancyFileReader(url: url)
        let buffer = Vacancy()
        var loaded: [Vacancy] = []
        // Один буфер на весь файл, у масив кладемо його копії (конструктор копій)
        while try reader >> buffer {
            loaded.append(Vacancy(copyOf: buffer))
        }
        vacancies = loaded
    }

    /// Записує всі вакансії у файл (оператор `<<`). Каталог не змінюється.
    ///
    /// - Throws: `VacancyError.fileWriteFailed`, якщо файл не вдалося записати.
    func save(to url: URL) throws {
        let writer = VacancyFileWriter(url: url)
        for vacancy in vacancies {
            writer << vacancy
        }
        try writer.save()
    }

    // MARK: - Допоміжні методи

    /// Позиція вакансії в масиві або `nil`. Порівнюємо посилання (`===`): шукаємо той самий об'єкт,
    /// а не вакансію з такими самими полями.
    private func position(of vacancy: Vacancy) -> Int? {
        for index in 0..<vacancies.count {
            if vacancies[index] === vacancy {
                return index
            }
        }
        return nil
    }

    /// Прибирає повтори (без урахування регістру; лишається перше написання) і сортує за абеткою.
    private func uniqueSorted(_ names: [String]) -> [String] {
        var result: [String] = []
        var seen: Set<String> = []
        for name in names {
            let key = name.lowercased()
            if seen.contains(key) {
                continue
            }
            seen.insert(key)
            result.append(name)
        }
        return result.sorted(by: { first, second in
            return first.localizedCaseInsensitiveCompare(second) == .orderedAscending
        })
    }
}
