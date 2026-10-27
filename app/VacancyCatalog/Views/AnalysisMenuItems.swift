//
//  AnalysisMenuItems.swift
//  Пункти меню «Аналіз»: «Усі вакансії», функції 1–6, «Виконати функцію».
//

import SwiftUI

/// Пункти меню «Аналіз» (Figma: `Organism/MainMenu`, екран S-13b).
///
/// Ті самі пункти — у головному меню (з гарячими клавішами ⌘0…⌘6, ⌘⏎) і в кнопці «Аналіз» на панелі
/// інструментів (без клавіш, щоб одна клавіша не була призначена двічі).
struct AnalysisMenuItems: View {

    /// Стан вікна.
    let viewModel: CatalogViewModel
    /// Чи показувати гарячі клавіші (лише в головному меню).
    let showsShortcuts: Bool

    var body: some View {
        Button {
            viewModel.showAll()
        } label: {
            Label("Усі вакансії", systemImage: "list.bullet")
        }
        .keyboardShortcut(shortcut("0"))

        Divider()

        ForEach(0..<viewModel.operations.count, id: \.self) { index in
            Button {
                viewModel.select(viewModel.operations[index])
            } label: {
                Label(viewModel.operations[index].title, systemImage: viewModel.operations[index].systemImage)
            }
            .keyboardShortcut(shortcut(KeyEquivalent(Character("\(index + 1)"))))
        }

        if showsShortcuts {
            Divider()
            Button("Виконати функцію") {
                viewModel.runSelectedOperation()
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(viewModel.selectedOperation?.canExecute != true)
        }
    }

    /// Гаряча клавіша ⌘ + `key` у головному меню; у меню панелі інструментів — без клавіші (`nil`).
    private func shortcut(_ key: KeyEquivalent) -> KeyboardShortcut? {
        if showsShortcuts {
            return KeyboardShortcut(key, modifiers: .command)
        }
        return nil
    }
}
