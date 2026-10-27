//
//  MainWindowView.swift
//  Головне вікно: сайдбар, таблиця вакансій (або порожній стан), панель деталей, рядок стану.
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
        .alert(viewModel.errorAlert?.errorDescription ?? "", isPresented: isErrorAlertPresented) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorAlert?.recoverySuggestion ?? "")
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

    /// Алерт показується, поки в `errorAlert` є помилка; кнопка «OK» закриває його і очищує помилку.
    private var isErrorAlertPresented: Binding<Bool> {
        return Binding(
            get: {
                return viewModel.errorAlert != nil
            },
            set: { isPresented in
                if isPresented == false {
                    viewModel.errorAlert = nil
                }
            }
        )
    }
}
