//
//  OperationPanelView.swift
//  Панель вибраної функції над таблицею: заголовок, пояснення, підсумок, параметри і «Виконати».
//

import SwiftUI

/// Панель функції 1–6 (Figma: `Organism/OperationPanel`, екрани S-03…S-08; прецеденти UC-11…UC-16).
///
/// Заголовок, пояснення і підсумок однакові для всіх функцій — їх дає базовий клас `CatalogOperation`.
/// Параметри свої в кожної функції: панель перевіряє тип операції (`as?`) і показує потрібні поля.
/// Ф.5 і ф.6 параметрів не мають — їхній результат з'являється одразу після вибору в сайдбарі.
struct OperationPanelView: View {

    /// Стан вікна.
    let viewModel: CatalogViewModel
    /// Вибрана функція.
    let operation: CatalogOperation

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Label("\(viewModel.number(of: operation)) · \(operation.title)", systemImage: operation.systemImage)
                    .font(.title3.weight(.semibold))
                Spacer()
                Text(viewModel.result?.summary ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(operation.helpText)
                .font(.caption)
                .foregroundStyle(.secondary)
            parameters
        }
        .padding(.horizontal, AppSpacing.l)
        .padding(.vertical, AppSpacing.m)
    }

    /// Поля параметрів вибраної функції і кнопка «Виконати».
    @ViewBuilder
    private var parameters: some View {
        if let search = operation as? SearchByTitleAndCompanyOperation {
            HStack(alignment: .bottom, spacing: AppSpacing.m) {
                TitleCompanySearch(operation: search, onSubmit: run)
                runButton
            }
        } else if let search = operation as? SearchByTechnologyOperation {
            HStack(alignment: .bottom, spacing: AppSpacing.m) {
                TechnologyPicker(operation: search, technologies: viewModel.catalog.allTechnologies, onSubmit: run)
                runButton
            }
        } else if let filter = operation as? FilterByLevelAndFormatOperation {
            HStack(alignment: .bottom, spacing: AppSpacing.m) {
                LevelFormatFilter(operation: filter, onChange: run)
                runButton
            }
        } else if let sort = operation as? SortByAverageSalaryOperation {
            HStack(alignment: .bottom, spacing: AppSpacing.m) {
                SortDirectionControl(operation: sort, onChange: run)
                runButton
            }
        }
    }

    /// «Виконати» (⌘⏎). Неактивна, поки параметри не заповнені (`canExecute`, ф.1 і ф.2).
    private var runButton: some View {
        Button("Виконати") {
            run()
        }
        .buttonStyle(.borderedProminent)
        .keyboardShortcut(.return, modifiers: .command)
        .disabled(operation.canExecute == false)
        .help("Виконати функцію (⌘⏎)")
    }

    /// Виконує функцію, якщо параметри заповнені.
    private func run() {
        if operation.canExecute {
            viewModel.run(operation)
        }
    }
}
