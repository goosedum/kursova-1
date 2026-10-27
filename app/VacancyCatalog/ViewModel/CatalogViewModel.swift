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

    // MARK: - Функції 1–6

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
        hasUnsavedChanges = false
        selectedVacancyIDs = []
        showAll()
    }

    /// «Відкрити…»: каталог з файлу. Якщо в рядку помилка — алерт, каталог не змінюється (D-23).
    func open(url: URL) {
        withAccess(to: url) {
            try catalog.load(from: url)
            currentFileURL = url
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
        hasUnsavedChanges = false
        selectedVacancyIDs = []
        showAll()
    }

    // MARK: - Допоміжні методи

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
