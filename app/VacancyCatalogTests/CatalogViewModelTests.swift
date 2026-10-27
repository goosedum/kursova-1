//
//  CatalogViewModelTests.swift
//  Тести стану вікна: функції, форма через копію, вибір кількох вакансій, файли, незбережені зміни, алерти.
//

import Foundation
import Testing
@testable import VacancyCatalog

/// Тести класу `CatalogViewModel` (T-VM-* з `.claude/plan/05-testing.md`; рішення D-23, D-24, D-25, D-31).
@MainActor
struct CatalogViewModelTests {

    /// Стан вікна з відкритим демо-файлом (28 вакансій).
    private func makeViewModel() throws -> CatalogViewModel {
        let viewModel = CatalogViewModel()
        viewModel.open(url: try TestFiles.fixture("vacancies"))
        return viewModel
    }

    // MARK: - Початковий стан і функції

    @Test("Новий стан: порожній каталог, 6 функцій, нічого не вибрано, змін немає")
    func initialState() {
        let viewModel = CatalogViewModel()
        #expect(viewModel.catalog.vacancies.isEmpty)
        #expect(viewModel.operations.count == 6)
        #expect(viewModel.operations[0] is SearchByTitleAndCompanyOperation)
        #expect(viewModel.operations[5] is GroupBySpecializationOperation)
        #expect(viewModel.selectedOperation == nil)
        #expect(viewModel.result == nil)
        #expect(viewModel.hasUnsavedChanges == false)
        #expect(viewModel.errorAlert == nil)
    }

    @Test("run показує результат функції, showAll — знову весь каталог")
    func runAndShowAll() throws {
        let viewModel = try makeViewModel()
        #expect(viewModel.displayedGroups[0].vacancies.count == 28)

        let operation = viewModel.operations[5]
        viewModel.run(operation)
        #expect(viewModel.selectedOperation === operation)
        #expect(viewModel.displayedGroups.count == 8)
        #expect(viewModel.catalog.vacancies.count == 28)

        viewModel.showAll()
        #expect(viewModel.selectedOperation == nil)
        #expect(viewModel.displayedGroups.count == 1)
        #expect(viewModel.displayedGroups[0].vacancies.count == 28)
    }

    @Test("T-VM: помилка функції потрапляє в errorAlert (ф.4 на порожньому каталозі)")
    func operationErrorBecomesAlert() {
        let viewModel = CatalogViewModel()
        viewModel.run(viewModel.operations[3])
        #expect(viewModel.errorAlert == VacancyError.emptyCatalog)
        #expect(viewModel.result == nil)
    }

    // MARK: - Форма

    @Test("Додати: нова вакансія потрапляє в кінець каталогу і стає вибраною")
    func addVacancy() throws {
        let viewModel = try makeViewModel()
        viewModel.newVacancy()
        #expect(viewModel.isFormPresented)
        #expect(viewModel.isEditingExisting == false)

        let draft = try #require(viewModel.editingDraft)
        draft.company = "NewCo"
        draft.title = "Swift Developer"
        draft.specialization = "Mobile"
        draft.minSalary = 1000
        draft.maxSalary = 2000
        draft.technologies = ["Swift"]
        viewModel.saveDraft()

        #expect(viewModel.catalog.vacancies.count == 29)
        #expect(viewModel.catalog.vacancies[28] === draft)
        #expect(viewModel.selectedVacancyIDs == [draft.id])
        #expect(viewModel.hasUnsavedChanges)
        #expect(viewModel.isFormPresented == false)
        #expect(viewModel.editingDraft == nil)
    }

    @Test("T-VM: помилка в даних форми → алерт, форма відкрита, каталог не змінився (D-31)")
    func invalidDraftKeepsFormOpen() throws {
        let viewModel = try makeViewModel()
        viewModel.newVacancy()
        viewModel.saveDraft()

        #expect(viewModel.errorAlert == VacancyError.emptyField(name: "Компанія"))
        #expect(viewModel.isFormPresented)
        #expect(viewModel.editingDraft != nil)
        #expect(viewModel.catalog.vacancies.count == 28)
        #expect(viewModel.hasUnsavedChanges == false)
    }

    @Test("T-VM: редагування копії + «Скасувати» не змінює оригінал")
    func cancelEditingKeepsOriginal() throws {
        let viewModel = try makeViewModel()
        let original = viewModel.catalog.vacancies[0]
        viewModel.selectedVacancyIDs = [original.id]
        viewModel.editSelected()
        #expect(viewModel.isEditingExisting)

        let draft = try #require(viewModel.editingDraft)
        #expect(draft !== original)
        draft.title = "Змінена посада"
        viewModel.cancelEditing()

        #expect(original.title == "Junior iOS Developer")
        #expect(viewModel.catalog.vacancies[0] === original)
        #expect(viewModel.isFormPresented == false)
        #expect(viewModel.hasUnsavedChanges == false)
    }

    @Test("Редагування копії + «Зберегти»: копія стає на місце оригіналу, результат функції оновлюється")
    func saveEditedCopy() throws {
        let viewModel = try makeViewModel()
        let technology = viewModel.operations[1] as? SearchByTechnologyOperation
        technology?.technology = "Swift"
        viewModel.run(viewModel.operations[1])
        #expect(viewModel.result?.vacancyCount == 3)

        let original = viewModel.catalog.vacancies[0]
        viewModel.selectedVacancyIDs = [original.id]
        viewModel.editSelected()
        let draft = try #require(viewModel.editingDraft)
        draft.technologies = ["Kotlin"]
        viewModel.saveDraft()

        #expect(viewModel.catalog.vacancies[0] === draft)
        #expect(viewModel.selectedVacancyIDs == [draft.id])
        #expect(viewModel.hasUnsavedChanges)
        // Функцію виконано повторно: вакансії № 1 зі Swift більше немає
        #expect(viewModel.result?.vacancyCount == 2)
    }

    // MARK: - Вибір кількох вакансій (D-25)

    @Test("T-VM: редагувати й дублювати можна лише при одній вибраній")
    func editAndDuplicateNeedOneSelected() throws {
        let viewModel = try makeViewModel()
        #expect(viewModel.canEditSelected == false)
        viewModel.editSelected()
        #expect(viewModel.isFormPresented == false)

        viewModel.selectedVacancyIDs = [viewModel.catalog.vacancies[0].id, viewModel.catalog.vacancies[1].id]
        #expect(viewModel.canEditSelected == false)
        #expect(viewModel.canDeleteSelected)
        viewModel.editSelected()
        viewModel.duplicateSelected()
        #expect(viewModel.isFormPresented == false)
        #expect(viewModel.catalog.vacancies.count == 28)
    }

    @Test("Дублювати: копія одразу після оригіналу, вибрана копія")
    func duplicateInsertsAfterOriginal() throws {
        let viewModel = try makeViewModel()
        let original = viewModel.catalog.vacancies[2]
        viewModel.selectedVacancyIDs = [original.id]
        viewModel.duplicateSelected()

        let copy = viewModel.catalog.vacancies[3]
        #expect(viewModel.catalog.vacancies.count == 29)
        #expect(copy !== original)
        #expect(copy.title == original.title)
        #expect(viewModel.selectedVacancyIDs == [copy.id])
        #expect(viewModel.hasUnsavedChanges)
    }

    @Test("T-VM: видалення 3 вибраних (D-25); тексти питання")
    func deleteThreeSelected() throws {
        let viewModel = try makeViewModel()
        let first = viewModel.catalog.vacancies[0]
        viewModel.selectedVacancyIDs = [first.id]
        #expect(viewModel.deleteConfirmationTitle == "Видалити вакансію «Junior iOS Developer» (ByteForge)?")

        viewModel.selectedVacancyIDs = [first.id, viewModel.catalog.vacancies[5].id, viewModel.catalog.vacancies[9].id]
        #expect(viewModel.deleteConfirmationTitle == "Видалити 3 вибрані вакансії?")
        viewModel.isDeleteConfirmationPresented = true
        viewModel.deleteSelected()

        #expect(viewModel.catalog.vacancies.count == 25)
        #expect(viewModel.catalog.vacancies[0] !== first)
        #expect(viewModel.selectedVacancyIDs.isEmpty)
        #expect(viewModel.isDeleteConfirmationPresented == false)
        #expect(viewModel.hasUnsavedChanges)
    }

    @Test("Видалили всі вакансії, коли показано ф.4 — таблиця повертається до «Усі вакансії» без алерта")
    func deleteAllWhileSorted() throws {
        let viewModel = try makeViewModel()
        viewModel.run(viewModel.operations[3])
        var allIDs: Set<UUID> = []
        for vacancy in viewModel.catalog.vacancies {
            allIDs.insert(vacancy.id)
        }
        viewModel.selectedVacancyIDs = allIDs
        viewModel.deleteSelected()

        #expect(viewModel.catalog.vacancies.isEmpty)
        #expect(viewModel.selectedOperation == nil)
        #expect(viewModel.result == nil)
        #expect(viewModel.errorAlert == nil)
    }

    // MARK: - Файли і незбережені зміни (D-24)

    @Test("Відкрити файл: каталог, поточний файл, змін немає")
    func openFile() throws {
        let url = try TestFiles.fixture("vacancies")
        let viewModel = CatalogViewModel()
        viewModel.open(url: url)
        #expect(viewModel.catalog.vacancies.count == 28)
        #expect(viewModel.currentFileURL == url)
        #expect(viewModel.hasUnsavedChanges == false)
    }

    @Test("Відкрити помилковий файл: алерт з номером рядка, відкритий каталог і файл не змінились (D-23)")
    func openBrokenFile() throws {
        let viewModel = try makeViewModel()
        let fileBefore = viewModel.currentFileURL
        viewModel.open(url: try TestFiles.fixture("broken-salary"))

        #expect(viewModel.errorAlert == VacancyError.invalidNumber(line: 6, field: "мінімальна зарплата", value: "abc"))
        #expect(viewModel.catalog.vacancies.count == 28)
        #expect(viewModel.currentFileURL == fileBefore)
    }

    @Test("T-VM: зміни ставлять hasUnsavedChanges, «Зберегти як» і «Відкрити» знімають")
    func unsavedChangesFlag() throws {
        let viewModel = try makeViewModel()
        viewModel.selectedVacancyIDs = [viewModel.catalog.vacancies[0].id]
        viewModel.deleteSelected()
        #expect(viewModel.hasUnsavedChanges)

        let url = TestFiles.temporaryURL()
        viewModel.saveAs(url: url)
        #expect(viewModel.hasUnsavedChanges == false)
        #expect(viewModel.currentFileURL == url)

        // Збережений файл відкривається з тими самими 27 вакансіями
        viewModel.selectedVacancyIDs = [viewModel.catalog.vacancies[0].id]
        viewModel.duplicateSelected()
        #expect(viewModel.hasUnsavedChanges)
        viewModel.open(url: url)
        #expect(viewModel.catalog.vacancies.count == 27)
        #expect(viewModel.hasUnsavedChanges == false)
    }

    @Test("«Зберегти» без поточного файлу показує «Зберегти як…»; з файлом — записує в нього")
    func saveWithAndWithoutFile() throws {
        let viewModel = CatalogViewModel()
        viewModel.loadDemoData()
        viewModel.save()
        #expect(viewModel.isSavePanelPresented)

        let url = TestFiles.temporaryURL()
        viewModel.saveAs(url: url)
        viewModel.selectedVacancyIDs = [viewModel.catalog.vacancies[0].id]
        viewModel.deleteSelected()
        viewModel.save()
        #expect(viewModel.hasUnsavedChanges == false)

        let reopened = VacancyCatalog()
        try reopened.load(from: url)
        #expect(reopened.vacancies.count == 27)
    }

    @Test("Демо-дані: 28 вакансій з ресурсів програми, поточного файлу немає")
    func demoData() {
        let viewModel = CatalogViewModel()
        viewModel.loadDemoData()
        #expect(viewModel.errorAlert == nil)
        #expect(viewModel.catalog.vacancies.count == 28)
        #expect(viewModel.currentFileURL == nil)
        #expect(viewModel.hasUnsavedChanges == false)
    }

    @Test("Новий каталог: порожньо, без файлу, без змін, показ «Усі вакансії»")
    func newCatalog() throws {
        let viewModel = try makeViewModel()
        viewModel.run(viewModel.operations[5])
        viewModel.selectedVacancyIDs = [viewModel.catalog.vacancies[0].id]
        viewModel.newCatalog()

        #expect(viewModel.catalog.vacancies.isEmpty)
        #expect(viewModel.currentFileURL == nil)
        #expect(viewModel.hasUnsavedChanges == false)
        #expect(viewModel.selectedVacancyIDs.isEmpty)
        #expect(viewModel.result == nil)
    }

    @Test("Помилка запису → алерт fileWriteFailed, ознака змін лишається")
    func saveErrorKeepsUnsavedFlag() throws {
        let viewModel = try makeViewModel()
        viewModel.selectedVacancyIDs = [viewModel.catalog.vacancies[0].id]
        viewModel.deleteSelected()

        let folder = FileManager.default.temporaryDirectory.appending(path: "no-such-folder-\(UUID().uuidString)")
        viewModel.saveAs(url: folder.appending(path: "catalog.txt"))
        #expect(viewModel.errorAlert == VacancyError.fileWriteFailed(path: "catalog.txt"))
        #expect(viewModel.hasUnsavedChanges)
    }
}
