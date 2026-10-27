//
//  MainWindowView.swift
//  Головне вікно: сайдбар, таблиця вакансій (або порожній стан), панель деталей, рядок стану, форма, файли, алерти.
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// Головне вікно програми (Figma: `Template/MainWindow`, екрани S-01, S-02).
///
/// `NavigationSplitView` — системне вікно з бічною панеллю: ліворуч сайдбар, праворуч вміст.
/// Панель деталей (`inspector`) схована за кнопкою на панелі інструментів (рішення D-30).
/// Скло Liquid Glass панель інструментів і сайдбар отримують від системи самі — власного скла тут немає.
struct MainWindowView: View {

    /// Стан вікна. `@Bindable` — щоб передавати його властивості як зв'язки (`$viewModel.…`).
    @Bindable var viewModel: CatalogViewModel

    /// Чи показана панель деталей праворуч (за замовчуванням схована, D-30).
    @State private var isInspectorPresented = false

    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
        } detail: {
            VStack(spacing: 0) {
                // Панель вибраної функції над таблицею (крок 4.11)
                if let operation = viewModel.selectedOperation {
                    OperationPanelView(viewModel: viewModel, operation: operation)
                    Divider()
                }
                content
            }
            // VStack займає всю висоту вікна, навіть коли вміст невисокий (порожній стан) — інакше рядок стану
            // опинився б посередині вікна, під порожнім станом
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                StatusBarView(viewModel: viewModel)
            }
            .inspector(isPresented: $isInspectorPresented) {
                VacancyInspectorView(viewModel: viewModel)
                    .inspectorColumnWidth(300)
            }
            .toolbar {
                fileButtons
                vacancyButtons
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isInspectorPresented.toggle()
                    } label: {
                        Label("Деталі", systemImage: "sidebar.right")
                    }
                    .help("Показати або сховати панель деталей")
                }
            }
        }
        .navigationTitle("Каталог вакансій")
        .navigationSubtitle(viewModel.windowSubtitle)
        // «Відкрити…» — системне вікно вибору текстового файлу (UC-02)
        .fileImporter(isPresented: $viewModel.isOpenPanelPresented, allowedContentTypes: [.plainText]) { result in
            switch result {
            case .success(let url):
                viewModel.open(url: url)
            case .failure:
                // Вікно вибору файлу не відкрилося — нічого не змінюємо
                break
            }
        }
        // «Зберегти як…» — коли ViewModel просить вікно вибору місця (UC-04)
        .onChange(of: viewModel.isSavePanelPresented) {
            if viewModel.isSavePanelPresented {
                showSavePanel()
            }
        }
        // «Зберегти зміни в каталозі?» перед «Відкрити», «Новий каталог», «Демо-дані» (UC-22, D-24)
        .alert("Зберегти зміни в каталозі?", isPresented: $viewModel.isUnsavedChangesAlertPresented) {
            Button("Зберегти") {
                viewModel.saveChangesAndContinue()
            }
            .keyboardShortcut(.defaultAction)
            Button("Не зберігати", role: .destructive) {
                viewModel.discardChangesAndContinue()
            }
            Button("Скасувати", role: .cancel) {
                viewModel.cancelPendingAction()
            }
        } message: {
            Text(viewModel.unsavedChangesMessage)
        }
        // Форма вакансії — лист поверх вікна (UC-07, UC-08)
        .sheet(isPresented: $viewModel.isFormPresented) {
            if let draft = viewModel.editingDraft {
                VacancyFormView(viewModel: viewModel, draft: draft)
            }
        }
        // Підтвердження видалення однієї або кількох вибраних вакансій (UC-10, D-25)
        .alert(viewModel.deleteConfirmationTitle, isPresented: $viewModel.isDeleteConfirmationPresented) {
            Button("Видалити", role: .destructive) {
                viewModel.deleteSelected()
            }
            Button("Скасувати", role: .cancel) {}
        } message: {
            Text(viewModel.deleteConfirmationMessage)
        }
        .alert(viewModel.errorAlert?.alertTitle ?? "", isPresented: isErrorAlertPresented) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorAlert?.alertMessage ?? "")
        }
    }

    /// Вміст праворуч від сайдбару: порожній стан, «Нічого не знайдено» або таблиця.
    @ViewBuilder
    private var content: some View {
        if viewModel.isCatalogEmpty {
            EmptyStateView(viewModel: viewModel)
        } else if viewModel.isNothingFound {
            NothingFoundView(viewModel: viewModel)
        } else {
            VacancyTableView(viewModel: viewModel)
        }
    }

    /// Кнопки файлу на панелі інструментів: «Відкрити» і «Зберегти» (Figma: `Organism/Toolbar`).
    private var fileButtons: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                viewModel.requestOpen()
            } label: {
                Label("Відкрити", systemImage: "folder")
            }
            .help("Відкрити каталог з файлу (⌘O)")
            Button {
                viewModel.save()
            } label: {
                Label("Зберегти", systemImage: "square.and.arrow.down")
            }
            .help("Зберегти каталог у файл (⌘S)")
        }
    }

    /// Кнопки вакансій на панелі інструментів: додати, редагувати, дублювати, видалити, меню «Аналіз»
    /// (Figma: `Organism/Toolbar`). Гарячі клавіші до цих дій дає головне меню (`AppCommands`).
    @ToolbarContentBuilder
    private var vacancyButtons: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                viewModel.newVacancy()
            } label: {
                Label("Додати", systemImage: "plus")
            }
            .help("Додати вакансію (⌘N)")
            Button {
                viewModel.editSelected()
            } label: {
                Label("Редагувати", systemImage: "pencil")
            }
            .help("Редагувати вибрану вакансію (⌘E)")
            .disabled(viewModel.canEditSelected == false)
            Button {
                viewModel.duplicateSelected()
            } label: {
                Label("Дублювати", systemImage: "square.on.square")
            }
            .help("Дублювати вибрану вакансію (⌘D)")
            .disabled(viewModel.canEditSelected == false)
            Button {
                viewModel.isDeleteConfirmationPresented = true
            } label: {
                Label("Видалити", systemImage: "trash")
            }
            .help("Видалити вибрані вакансії (⌘⌫)")
            .disabled(viewModel.canDeleteSelected == false)
        }
        ToolbarItem {
            Menu {
                AnalysisMenuItems(viewModel: viewModel, showsShortcuts: false)
            } label: {
                Label("Аналіз", systemImage: "chart.bar.doc.horizontal")
            }
            .help("Функції 1–6 (⌘1…⌘6)")
        }
    }

    /// Вікно «Зберегти як…».
    ///
    /// SwiftUI має готове вікно збереження лише для «документів», а наш каталог записує у файл `VacancyFileWriter`
    /// (оператор `<<`), тому тут — системне вікно AppKit `NSSavePanel`: воно лише питає, куди зберегти.
    /// Вікно показується листом, прикріпленим до вікна каталогу (`beginSheetModal`), — тож воно завжди з'являється
    /// поверх каталогу, а не окремо деінде на екрані. Коли користувач натисне «Зберегти» або «Скасувати»,
    /// виконується блок `{ response in … }`.
    private func showSavePanel() {
        let panel = NSSavePanel()
        panel.title = "Зберегти каталог"
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = viewModel.currentFileURL?.lastPathComponent ?? "vacancies.txt"

        // mainWindow — вікно каталогу, навіть коли на ньому ще висить алерт «Зберегти зміни?» (той — keyWindow)
        guard let window = NSApp.mainWindow ?? NSApp.keyWindow else {
            // Вікна немає (програму згорнуто) — нічого не показуємо, щоб наступне ⌘S спрацювало знову
            viewModel.isSavePanelPresented = false
            viewModel.cancelPendingAction()
            return
        }
        panel.beginSheetModal(for: window) { response in
            viewModel.isSavePanelPresented = false
            if response == .OK, let url = panel.url {
                viewModel.saveAs(url: url)
            } else {
                viewModel.cancelPendingAction()
            }
        }
    }

    /// Алерт помилки вікна. Поки відкрита форма, помилку показує сама форма (алерт поверх листа).
    private var isErrorAlertPresented: Binding<Bool> {
        return Binding(
            get: {
                return viewModel.errorAlert != nil && viewModel.isFormPresented == false
            },
            set: { isPresented in
                if isPresented == false {
                    viewModel.errorAlert = nil
                }
            }
        )
    }
}
