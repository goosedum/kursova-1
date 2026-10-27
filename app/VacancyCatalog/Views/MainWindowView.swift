//
//  MainWindowView.swift
//  Головне вікно: сайдбар, таблиця вакансій (або порожній стан), панель деталей, рядок стану, форма, алерти.
//

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
    /// Чи показане вікно вибору файлу «Відкрити…».
    @State private var isFileImporterPresented = false

    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
        } detail: {
            content
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    StatusBarView(viewModel: viewModel)
                }
                .inspector(isPresented: $isInspectorPresented) {
                    VacancyInspectorView(viewModel: viewModel)
                        .inspectorColumnWidth(300)
                }
                .toolbar {
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
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.plainText]) { result in
            switch result {
            case .success(let url):
                viewModel.open(url: url)
            case .failure:
                // Вікно вибору файлу не відкрилося — нічого не змінюємо
                break
            }
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
            EmptyStateView(viewModel: viewModel, openFile: {
                isFileImporterPresented = true
            })
        } else if viewModel.isNothingFound {
            NothingFoundView(viewModel: viewModel)
        } else {
            VacancyTableView(viewModel: viewModel)
        }
    }

    /// Кнопки вакансій на панелі інструментів: додати, редагувати, дублювати, видалити (Figma: `Organism/Toolbar`).
    /// Гарячі клавіші до них додає головне меню (крок 4.12).
    private var vacancyButtons: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                viewModel.newVacancy()
            } label: {
                Label("Додати", systemImage: "plus")
            }
            .help("Додати вакансію")
            Button {
                viewModel.editSelected()
            } label: {
                Label("Редагувати", systemImage: "pencil")
            }
            .help("Редагувати вибрану вакансію")
            .disabled(viewModel.canEditSelected == false)
            Button {
                viewModel.duplicateSelected()
            } label: {
                Label("Дублювати", systemImage: "square.on.square")
            }
            .help("Дублювати вибрану вакансію")
            .disabled(viewModel.canEditSelected == false)
            Button {
                viewModel.isDeleteConfirmationPresented = true
            } label: {
                Label("Видалити", systemImage: "trash")
            }
            .help("Видалити вибрані вакансії")
            .disabled(viewModel.canDeleteSelected == false)
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
