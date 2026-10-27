//
//  SidebarView.swift
//  Бічна панель: «Усі вакансії» і функції 1–6 з номерами.
//

import SwiftUI

/// Сайдбар (Figma: `Organism/Sidebar`): розділ «Каталог» з лічильником вакансій і розділ «Функції» 1–6.
///
/// Вибраний пункт — номер: 0 — «Усі вакансії», 1…6 — функція з таким номером (як ⌘0…⌘6 у меню, крок 4.12).
struct SidebarView: View {

    /// Стан вікна.
    let viewModel: CatalogViewModel

    var body: some View {
        List(selection: selectedNumber) {
            Section("Каталог") {
                Label("Усі вакансії", systemImage: "list.bullet")
                    .badge(Text("\(viewModel.catalog.vacancies.count)"))
                    .tag(0)
            }
            Section("Функції") {
                ForEach(0..<viewModel.operations.count, id: \.self) { index in
                    Label(viewModel.operations[index].shortTitle, systemImage: viewModel.operations[index].systemImage)
                        .badge(Text("\(index + 1)"))
                        .tag(index + 1)
                        .help(viewModel.operations[index].title)
                }
            }
        }
        .navigationSplitViewColumnWidth(240)
    }

    /// Зв'язок між вибраним рядком списку і станом вікна.
    /// Читання — який пункт зараз вибраний; запис — користувач клацнув інший пункт.
    private var selectedNumber: Binding<Int?> {
        return Binding(
            get: {
                return number(of: viewModel.selectedOperation)
            },
            set: { newNumber in
                guard let number = newNumber, number >= 1, number <= viewModel.operations.count else {
                    viewModel.showAll()
                    return
                }
                viewModel.select(viewModel.operations[number - 1])
            }
        )
    }

    /// Номер функції в сайдбарі (1…6) або 0 для «Усі вакансії».
    private func number(of operation: CatalogOperation?) -> Int {
        guard let selected = operation else {
            return 0
        }
        for index in 0..<viewModel.operations.count {
            if viewModel.operations[index] === selected {
                return index + 1
            }
        }
        return 0
    }
}
