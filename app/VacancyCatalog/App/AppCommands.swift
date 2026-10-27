//
//  AppCommands.swift
//  Головне меню програми: «Вакансія», «Аналіз», «Довідка» з гарячими клавішами.
//

import SwiftUI

/// Пункти головного меню (Figma: `Organism/MainMenu`, екрани S-13a, S-13b; гарячі клавіші — `04-use-cases.md`, §5).
///
/// `Commands` — опис меню в SwiftUI. Кожен пункт викликає той самий метод ViewModel, що й кнопка
/// на панелі інструментів чи в контекстному меню: одна дія — однакові назва і поведінка скрізь.
struct AppCommands: Commands {

    /// Стан вікна (той самий об'єкт, що й у вікні).
    let viewModel: CatalogViewModel

    /// Відкриває вікно за його `id` (вікно «Довідка»).
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        // Системний пункт «Новий» забирав би ⌘N; пункти меню «Файл» з'являться на кроці 4.13
        CommandGroup(replacing: .newItem) {}

        CommandMenu("Вакансія") {
            Button("Додати вакансію…") {
                viewModel.newVacancy()
            }
            .keyboardShortcut("n", modifiers: .command)
            .disabled(viewModel.isFormPresented)

            Button("Редагувати…") {
                viewModel.editSelected()
            }
            .keyboardShortcut("e", modifiers: .command)
            .disabled(viewModel.canEditSelected == false || viewModel.isFormPresented)

            Button("Дублювати") {
                viewModel.duplicateSelected()
            }
            .keyboardShortcut("d", modifiers: .command)
            .disabled(viewModel.canEditSelected == false || viewModel.isFormPresented)

            Divider()

            Button("Видалити") {
                viewModel.isDeleteConfirmationPresented = true
            }
            .keyboardShortcut(.delete, modifiers: .command)
            .disabled(viewModel.canDeleteSelected == false || viewModel.isFormPresented)
        }

        CommandMenu("Аналіз") {
            AnalysisMenuItems(viewModel: viewModel, showsShortcuts: true)
        }

        // «Довідка» замість системного пункту «Довідка: <назва програми>»
        CommandGroup(replacing: .help) {
            Button("Довідка «Каталог вакансій»") {
                openWindow(id: "help")
            }
            .keyboardShortcut("?", modifiers: .command)
        }
    }
}
