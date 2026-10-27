//
//  Vacancy.swift
//  Вакансія для ІТ-спеціаліста: 8 полів, три конструктори, деструктор, перевірка й очищення даних.
//

import Foundation
import Observation

/// Вакансія для ІТ-спеціаліста — головний клас предметної області (варіант 13).
///
/// Це клас, а не структура: вакансія — сутність з ідентичністю, на один об'єкт посилаються таблиця,
/// панель деталей і форма. Тому для незалежної копії потрібен конструктор копій `init(copyOf:)`:
/// `let b = a` копіює лише посилання, а не сам об'єкт.
/// `@Observable` — інтерфейс оновлюється сам, коли змінюються поля.
@Observable
class Vacancy: Identifiable {

    // MARK: - Обмеження полів (docs/analysis/02-data-model.md, §1)

    /// Максимальна довжина назви компанії.
    static let maxCompanyLength = 60
    /// Максимальна довжина назви посади.
    static let maxTitleLength = 80
    /// Максимальна довжина спеціалізації.
    static let maxSpecializationLength = 40
    /// Найбільша кількість технологій.
    static let maxTechnologyCount = 15
    /// Максимальна довжина назви однієї технології.
    static let maxTechnologyLength = 30
    /// Найбільша дозволена зарплата, $ на місяць.
    static let maxSalary = 100_000

    // MARK: - Поля

    /// Унікальний ідентифікатор (не зберігається у файлі; новий для кожного об'єкта).
    let id: UUID
    /// Компанія-роботодавець.
    var company: String
    /// Назва посади.
    var title: String
    /// Спеціалізація: Backend, Mobile, Data Science…
    var specialization: String
    /// Рівень досвіду.
    var experienceLevel: ExperienceLevel
    /// Мінімальна запропонована зарплата, $ на місяць.
    var minSalary: Int
    /// Максимальна запропонована зарплата, $ на місяць.
    var maxSalary: Int
    /// Формат роботи.
    var workFormat: WorkFormat
    /// Перелік основних технологій.
    var technologies: [String]

    // MARK: - Конструктори і деструктор

    /// Конструктор за замовчуванням: «порожня» вакансія.
    ///
    /// Потрібна як заготовка для форми «Додати» і як буфер під час читання файлу (`reader >> vacancy`).
    /// Перевірку `validate()` така вакансія не проходить — це нормально.
    init() {
        id = UUID()
        company = ""
        title = ""
        specialization = ""
        experienceLevel = .junior
        minSalary = 0
        maxSalary = 0
        workFormat = .office
        technologies = []
    }

    /// Конструктор з параметрами: вакансія з усіма 8 полями.
    init(company: String, title: String, specialization: String, experienceLevel: ExperienceLevel,
         minSalary: Int, maxSalary: Int, workFormat: WorkFormat, technologies: [String]) {
        self.id = UUID()
        self.company = company
        self.title = title
        self.specialization = specialization
        self.experienceLevel = experienceLevel
        self.minSalary = minSalary
        self.maxSalary = maxSalary
        self.workFormat = workFormat
        self.technologies = technologies
    }

    /// Конструктор копій: новий об'єкт з тими самими даними, але з новим `id`.
    ///
    /// Масив `technologies` у Swift копіюється за значенням, тож зміна копії не змінює оригінал.
    /// Використовується під час редагування (форма працює з копією) і дублювання вакансії.
    convenience init(copyOf other: Vacancy) {
        self.init(company: other.company, title: other.title, specialization: other.specialization,
                  experienceLevel: other.experienceLevel, minSalary: other.minSalary, maxSalary: other.maxSalary,
                  workFormat: other.workFormat, technologies: other.technologies)
    }

    /// Деструктор: викликається автоматично, коли зникає останнє посилання на об'єкт (механізм ARC).
    deinit {
        #if DEBUG
        print("Вакансію \(id) знищено")
        #endif
    }

    // MARK: - Обчислювані властивості

    /// Середня запропонована зарплата: (мін + макс) / 2. Ключ сортування для функції 4.
    var averageSalary: Double {
        return Double(minSalary + maxSalary) / 2
    }

    /// Діапазон зарплати: макс − мін. Використовується у функції 5.
    var salaryRange: Int {
        return maxSalary - minSalary
    }

    // MARK: - Методи

    /// Чи вимагає вакансія технологію `name`: точний збіг назви без урахування регістру (рішення D-10).
    ///
    /// «swift» знаходить «Swift», але не «SwiftUI».
    func hasTechnology(_ name: String) -> Bool {
        let wanted = name.trimmingCharacters(in: .whitespaces).lowercased()
        for technology in technologies {
            if technology.trimmingCharacters(in: .whitespaces).lowercased() == wanted {
                return true
            }
        }
        return false
    }

    /// Прибирає пробіли на початку й у кінці текстових полів, а також порожні й повторні технології.
    ///
    /// Викликається перед збереженням вакансії в каталог і після читання з файлу.
    func normalize() {
        company = company.trimmingCharacters(in: .whitespaces)
        title = title.trimmingCharacters(in: .whitespaces)
        specialization = specialization.trimmingCharacters(in: .whitespaces)
        technologies = cleanedTechnologies()
    }

    /// Перевіряє дані вакансії за правилами з `docs/analysis/02-data-model.md`, §5. Поля не змінює.
    ///
    /// Поля перевіряються по черзі тими самими методами, що й під полями форми (`validateCompany()` …).
    /// - Throws: `VacancyError.emptyField`, `.fieldTooLong`, `.forbiddenCharacter`, `.salaryOutOfRange`,
    ///   `.minSalaryGreaterThanMax`, `.noTechnologies` або `.tooManyTechnologies` — першу знайдену помилку.
    func validate() throws {
        try validateCompany()
        try validateTitle()
        try validateSpecialization()
        try validateSalary()
        try validateTechnologies()
    }

    // MARK: - Перевірка окремих полів (для повідомлень під полями форми)

    /// Компанія: не порожня, до 60 символів, без «;».
    func validateCompany() throws {
        try checkText(company, name: "Компанія", limit: Vacancy.maxCompanyLength)
    }

    /// Посада: не порожня, до 80 символів, без «;».
    func validateTitle() throws {
        try checkText(title, name: "Посада", limit: Vacancy.maxTitleLength)
    }

    /// Спеціалізація: не порожня, до 40 символів, без «;».
    func validateSpecialization() throws {
        try checkText(specialization, name: "Спеціалізація", limit: Vacancy.maxSpecializationLength)
    }

    /// Зарплата: від 0 до 100 000 і мінімальна не більша за максимальну.
    func validateSalary() throws {
        for salary in [minSalary, maxSalary] {
            if salary < 0 || salary > Vacancy.maxSalary {
                throw VacancyError.salaryOutOfRange(value: salary)
            }
        }
        if minSalary > maxSalary {
            throw VacancyError.minSalaryGreaterThanMax(min: minSalary, max: maxSalary)
        }
    }

    /// Технології: від 1 до 15, кожна не довша за 30 символів, без «;» і «,».
    func validateTechnologies() throws {
        let cleaned = cleanedTechnologies()
        if cleaned.isEmpty {
            throw VacancyError.noTechnologies
        }
        if cleaned.count > Vacancy.maxTechnologyCount {
            throw VacancyError.tooManyTechnologies(limit: Vacancy.maxTechnologyCount)
        }
        for technology in cleaned {
            if technology.count > Vacancy.maxTechnologyLength {
                throw VacancyError.fieldTooLong(name: "Технологія", limit: Vacancy.maxTechnologyLength)
            }
            for character in [";", ","] {
                if technology.contains(character) {
                    throw VacancyError.forbiddenCharacter(name: "Технологія", character: character)
                }
            }
        }
    }

    // MARK: - Допоміжні методи

    /// Перевіряє одне текстове поле: не порожнє, не довше за `limit`, без символу «;».
    private func checkText(_ value: String, name: String, limit: Int) throws {
        let text = value.trimmingCharacters(in: .whitespaces)
        if text.isEmpty {
            throw VacancyError.emptyField(name: name)
        }
        if text.count > limit {
            throw VacancyError.fieldTooLong(name: name, limit: limit)
        }
        if text.contains(";") {
            throw VacancyError.forbiddenCharacter(name: name, character: ";")
        }
    }

    /// Технології без зайвих пробілів, порожніх елементів і повторів (без урахування регістру; лишається перша).
    private func cleanedTechnologies() -> [String] {
        var result: [String] = []
        var seen: Set<String> = []
        for technology in technologies {
            let name = technology.trimmingCharacters(in: .whitespaces)
            if name.isEmpty {
                continue
            }
            let key = name.lowercased()
            if seen.contains(key) {
                continue
            }
            seen.insert(key)
            result.append(name)
        }
        return result
    }
}
