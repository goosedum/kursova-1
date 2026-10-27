//
//  CatalogViewModel.swift
//  Стан головного вікна: каталог, вибрані вакансії, функція і результат, форма, файл, помилки.
//

import Foundation
import Observation

/// Стан головного вікна і дії користувача (прецеденти UC-01…UC-22 з `docs/analysis/04-use-cases.md`).
///
/// Вікна (Views) лише показують цей стан і викликають методи. Уся робота — у каталозі й операціях,
/// а тут — «хто що вибрав» і «що показати». Помилки моделі ловляться (`do-catch`) і стають алертом (`errorAlert`).
/// `@Observable` — інтерфейс оновлюється сам, коли змінюється будь-яка властивість.
@Observable
class CatalogViewModel {

    // MARK: - Стан

    /// Вакансії, з якими працює вікно.
    let catalog = VacancyCatalog()
    /// Функції 1–6 у порядку сайдбару. Тип елементів — базовий клас, тому всі виконуються однаково (поліморфізм).
    let operations: [CatalogOperation] = [
        SearchByTitleAndCompanyOperation(),
        SearchByTechnologyOperation(),
        FilterByLevelAndFormatOperation(),
        SortByAverageSalaryOperation(),
        SalaryRangeExtremesOperation(),
        GroupBySpecializationOperation()
    ]
    /// Вибрана в сайдбарі функція; `nil` — «Усі вакансії».
    var selectedOperation: CatalogOperation?
    /// Результат останнього виконання функції; `nil` — таблиця показує весь каталог.
    var result: OperationResult?
    /// Вибрані рядки таблиці (можна кілька, D-25).
    var selectedVacancyIDs: Set<UUID> = []

    /// Вакансія, яку зараз редагує форма: нова або **копія** існуючої (оригінал не змінюється до «Зберегти»).
    var editingDraft: Vacancy?
    /// Чи відкрита форма вакансії.
    var isFormPresented = false
    /// Оригінал, копію якого редагує форма; `nil` — форма додає нову вакансію.
    private var editingOriginal: Vacancy?

    /// Файл, з якого відкрито каталог або куди його збережено; `nil` — новий каталог або демо-дані.
    var currentFileURL: URL?
    /// Чи є зміни, яких ще немає у файлі (D-24).
    var hasUnsavedChanges = false
    /// Чи відкрито вбудовані демо-дані (для назви каталогу в заголовку вікна).
    private(set) var isDemoCatalog = false

    /// Помилка, яку треба показати в алерті; після закриття алерта — `nil`.
    var errorAlert: VacancyError?
    /// Чи показати питання «Видалити …?».
    var isDeleteConfirmationPresented = false
    /// Чи показати вікно «Зберегти як…» (поточного файлу ще немає).
    var isSavePanelPresented = false

    // MARK: - Що показати

    /// Групи для таблиці: результат функції або весь каталог однією групою без заголовка.
    var displayedGroups: [VacancyGroup] {
        if let currentResult = result {
            return currentResult.groups
        }
        return [VacancyGroup(title: "", vacancies: catalog.vacancies)]
    }

    /// Вибрані вакансії в порядку каталогу.
    var selectedVacancies: [Vacancy] {
        var selected: [Vacancy] = []
        for vacancy in catalog.vacancies {
            if selectedVacancyIDs.contains(vacancy.id) {
                selected.append(vacancy)
            }
        }
        return selected
    }

    /// Редагувати і дублювати можна лише одну вибрану вакансію (D-25).
    var canEditSelected: Bool {
        return selectedVacancies.count == 1
    }

    /// Видаляти можна одну або кілька вибраних вакансій.
    var canDeleteSelected: Bool {
        return selectedVacancies.isEmpty == false
    }

    /// Чи редагує форма існуючу вакансію (заголовок «Редагування вакансії» замість «Нова вакансія»).
    var isEditingExisting: Bool {
        return editingOriginal != nil
    }

    /// Питання перед видаленням: «Видалити вакансію «Junior iOS Developer» (ByteForge)?» або «Видалити 3 вибрані вакансії?».
    var deleteConfirmationTitle: String {
        let selected = selectedVacancies
        if selected.count == 1 {
            return "Видалити вакансію «\(selected[0].title)» (\(selected[0].company))?"
        }
        let count = TextFormat.count(selected.count, one: "вибрану вакансію", few: "вибрані вакансії",
                                     many: "вибраних вакансій")
        return "Видалити \(count)?"
    }

    /// Пояснення під питанням про видалення (Figma S-18.1, S-18.2).
    var deleteConfirmationMessage: String {
        if selectedVacancies.count == 1 {
            return "Вакансію буде видалено з каталогу."
        }
        return "Вакансії буде видалено з каталогу."
    }

    /// Назва каталогу під заголовком вікна: ім'я файлу, «Демо-дані» або «Без назви».
    var catalogName: String {
        if let url = currentFileURL {
            return url.lastPathComponent
        }
        if isDemoCatalog {
            return "Демо-дані"
        }
        return "Без назви"
    }

    /// Підзаголовок вікна: «vacancies.txt · 28 вакансій».
    var windowSubtitle: String {
        return catalogName + " · " + TextFormat.vacancies(catalog.vacancies.count)
    }

    /// Ліва частина рядка стану (тексти з Figma S-01…S-08):
    /// «28 вакансій · vacancies.txt», «Показано 2 з 28 вакансій · …», «28 вакансій у 8 групах · …»,
    /// «28 вакансій · за спаданням середньої зарплати · …», «0 вакансій · новий каталог».
    var statusText: String {
        let total = catalog.vacancies.count
        var place = "новий каталог"
        if let url = currentFileURL {
            place = url.lastPathComponent
        } else if isDemoCatalog {
            place = "демо-дані"
        }

        guard let currentResult = result else {
            return TextFormat.vacancies(total) + " · " + place
        }
        let shown = currentResult.vacancyCount
        if shown == total && currentResult.groups.count > 1 {
            // Ф.6: усі вакансії, розкладені по групах
            let groups = TextFormat.count(currentResult.groups.count, one: "групі", few: "групах", many: "групах")
            return TextFormat.vacancies(total) + " у " + groups + " · " + place
        }
        if shown == total && total > 0 {
            // Ф.4: усі вакансії в іншому порядку — пишемо, в якому саме
            return TextFormat.vacancies(total) + " · " + lowercasedFirstLetter(currentResult.title) + " · " + place
        }
        // Ф.1–3, ф.5: частина каталогу («з 28 вакансій» — родовий відмінок)
        let of = TextFormat.count(total, one: "вакансії", few: "вакансій", many: "вакансій")
        return "Показано \(shown) з " + of + " · " + place
    }

    /// Технологія, яку виділити в таблиці: запит ф.2, коли показано її результат; інакше порожньо.
    var highlightedTechnology: String {
        if result == nil {
            return ""
        }
        if let search = selectedOperation as? SearchByTechnologyOperation {
            return search.technology
        }
        return ""
    }

    /// Заголовок колонки «Середня»: зі стрілкою напряму, коли показано результат ф.4 (S-06).
    var averageColumnTitle: String {
        if result == nil {
            return "Середня"
        }
        if let sort = selectedOperation as? SortByAverageSalaryOperation {
            if sort.ascending {
                return "Середня ↑"
            }
            return "Середня ↓"
        }
        return "Середня"
    }

    /// Номер функції, як у сайдбарі і меню: 1…6; 0 — «Усі вакансії» (`nil`).
    func number(of operation: CatalogOperation?) -> Int {
        guard let selected = operation else {
            return 0
        }
        for index in 0..<operations.count {
            if operations[index] === selected {
                return index + 1
            }
        }
        return 0
    }

    /// Порожній каталог — замість таблиці порожній стан з порадами (S-01).
    var isCatalogEmpty: Bool {
        return catalog.vacancies.isEmpty
    }

    /// Функція нічого не знайшла — замість таблиці «Нічого не знайдено».
    var isNothingFound: Bool {
        if let currentResult = result {
            return currentResult.vacancyCount == 0 && catalog.vacancies.isEmpty == false
        }
        return false
    }

    // MARK: - Функції 1–6

    /// Вибір функції в сайдбарі. Якщо параметри вже задані (ф.3–6), результат показується одразу;
    /// ф.1 і ф.2 спершу чекають на введення в панелі параметрів.
    func select(_ operation: CatalogOperation) {
        if operation.canExecute {
            run(operation)
        } else {
            selectedOperation = operation
            result = nil
        }
    }

    /// «Усі вакансії» в сайдбарі: таблиця показує весь каталог.
    func showAll() {
        selectedOperation = nil
        result = nil
    }

    /// Виконує функцію і показує її результат. Каталог не змінюється.
    ///
    /// Якщо функція кинула виняток (ф.4–6 на порожньому каталозі), показується алерт, а таблиця — весь каталог.
    func run(_ operation: CatalogOperation) {
        selectedOperation = operation
        do {
            // Тип змінної — CatalogOperation, виконується execute конкретного підкласу
            result = try operation.execute(on: catalog)
        } catch {
            result = nil
            showError(error)
        }
    }

    /// Контекстне меню рядка: «Знайти за технологією ▸ Swift» — функція 2 з цією технологією (S-12).
    func findVacancies(withTechnology technology: String) {
        for operation in operations {
            if let search = operation as? SearchByTechnologyOperation {
                search.technology = technology
                run(search)
                return
            }
        }
    }

    /// Контекстне меню рядка: «Вакансії компанії «PixelSoft»» — функція 1 лише за компанією (S-12).
    func findVacancies(ofCompany company: String) {
        for operation in operations {
            if let search = operation as? SearchByTitleAndCompanyOperation {
                search.titleQuery = ""
                search.companyQuery = company
                run(search)
                return
            }
        }
    }

    /// «Аналіз → Виконати функцію» (⌘⏎): виконує вибрану функцію, якщо її параметри заповнені.
    func runSelectedOperation() {
        guard let operation = selectedOperation else {
            return
        }
        if operation.canExecute {
            run(operation)
        }
    }

    // MARK: - Вакансії

    /// «Додати»: форма з порожньою вакансією (конструктор за замовчуванням).
    func newVacancy() {
        editingOriginal = nil
        editingDraft = Vacancy()
        isFormPresented = true
    }

    /// «Редагувати»: форма з **копією** вибраної вакансії. Лише коли вибрано рівно одну.
    func editSelected() {
        if canEditSelected == false {
            return
        }
        let original = selectedVacancies[0]
        editingOriginal = original
        editingDraft = Vacancy(copyOf: original)
        isFormPresented = true
    }

    /// «Зберегти» у формі: додає нову вакансію або ставить копію на місце оригіналу.
    ///
    /// Якщо дані неправильні, каталог кидає `VacancyError` — показуємо алерт, форма лишається відкритою (D-31).
    func saveDraft() {
        guard let draft = editingDraft else {
            return
        }
        do {
            if let original = editingOriginal {
                try catalog.replace(original, with: draft)
            } else {
                try catalog.add(draft)
            }
        } catch {
            showError(error)
            return
        }
        selectedVacancyIDs = [draft.id]
        hasUnsavedChanges = true
        closeForm()
        refreshResult()
    }

    /// «Скасувати» у формі: копія відкидається, оригінал не змінився.
    func cancelEditing() {
        closeForm()
    }

    /// «Дублювати»: копія вибраної вакансії одразу після оригіналу; копія стає вибраною (UC-09).
    func duplicateSelected() {
        if canEditSelected == false {
            return
        }
        let original = selectedVacancies[0]
        let copy = Vacancy(copyOf: original)
        do {
            try catalog.insert(copy, after: original)
        } catch {
            showError(error)
            return
        }
        selectedVacancyIDs = [copy.id]
        hasUnsavedChanges = true
        refreshResult()
    }

    /// «Видалити» в питанні-підтвердженні: видаляє всі вибрані вакансії (D-25).
    func deleteSelected() {
        let selected = selectedVacancies
        for vacancy in selected {
            catalog.remove(vacancy)
        }
        selectedVacancyIDs = []
        isDeleteConfirmationPresented = false
        if selected.isEmpty == false {
            hasUnsavedChanges = true
            refreshResult()
        }
    }

    // MARK: - Файли

    /// «Новий каталог»: порожній каталог без файлу.
    func newCatalog() {
        catalog.removeAll()
        currentFileURL = nil
        isDemoCatalog = false
        hasUnsavedChanges = false
        selectedVacancyIDs = []
        showAll()
    }

    /// «Відкрити…»: каталог з файлу. Якщо в рядку помилка — алерт, каталог не змінюється (D-23).
    func open(url: URL) {
        withAccess(to: url) {
            try catalog.load(from: url)
            currentFileURL = url
            isDemoCatalog = false
            hasUnsavedChanges = false
            selectedVacancyIDs = []
            showAll()
        }
    }

    /// «Зберегти»: у поточний файл. Якщо файлу ще немає — показати «Зберегти як…».
    func save() {
        guard let url = currentFileURL else {
            isSavePanelPresented = true
            return
        }
        withAccess(to: url) {
            try catalog.save(to: url)
            hasUnsavedChanges = false
        }
    }

    /// «Зберегти як…»: у вибраний файл, який стає поточним.
    func saveAs(url: URL) {
        withAccess(to: url) {
            try catalog.save(to: url)
            currentFileURL = url
            isDemoCatalog = false
            hasUnsavedChanges = false
        }
    }

    /// «Демо-дані»: вбудований каталог з 28 вакансій (копія `samples/vacancies.txt` у ресурсах програми).
    ///
    /// Поточного файлу немає — «Зберегти» спитає, куди записати (у ресурси програми писати не можна).
    func loadDemoData() {
        guard let url = Bundle.main.url(forResource: "vacancies", withExtension: "txt") else {
            errorAlert = VacancyError.fileNotFound(path: "vacancies.txt")
            return
        }
        do {
            try catalog.load(from: url)
        } catch {
            showError(error)
            return
        }
        currentFileURL = nil
        isDemoCatalog = true
        hasUnsavedChanges = false
        selectedVacancyIDs = []
        showAll()
    }

    // MARK: - Допоміжні методи

    /// «За спаданням …» → «за спаданням …» (для середини речення в рядку стану).
    private func lowercasedFirstLetter(_ text: String) -> String {
        guard let first = text.first else {
            return text
        }
        return first.lowercased() + text.dropFirst()
    }

    /// Закриває форму і забуває чернетку.
    private func closeForm() {
        isFormPresented = false
        editingDraft = nil
        editingOriginal = nil
    }

    /// Після зміни каталогу виконує вибрану функцію ще раз, щоб результат був актуальним (UC-11, A2).
    /// Якщо функцію виконати вже не можна (наприклад, видалили всі вакансії), показує весь каталог без алерта.
    private func refreshResult() {
        guard let operation = selectedOperation else {
            return
        }
        do {
            result = try operation.execute(on: catalog)
        } catch {
            showAll()
        }
    }

    /// Виконує дію з файлом і ловить її помилку.
    ///
    /// Програма працює в пісочниці (App Sandbox): файл, вибраний у вікні «Відкрити» чи «Зберегти», доступний лише
    /// між `startAccessingSecurityScopedResource()` і `stopAccessingSecurityScopedResource()`.
    /// `defer` виконується наприкінці методу за будь-якого виходу — і після успіху, і після помилки.
    private func withAccess(to url: URL, _ action: () throws -> Void) {
        let hasAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        do {
            try action()
        } catch {
            showError(error)
        }
    }

    /// Показує помилку в алерті.
    private func showError(_ error: Error) {
        if let vacancyError = error as? VacancyError {
            errorAlert = vacancyError
        } else {
            // Модель кидає лише VacancyError, тож сюди програма потрапити не може
            assertionFailure("Неочікувана помилка: \(error)")
        }
    }
}
