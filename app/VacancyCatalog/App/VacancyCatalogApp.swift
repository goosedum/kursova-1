//
//  VacancyCatalogApp.swift
//  Точка входу програми: одне головне вікно «Каталог вакансій».
//

import SwiftUI

/// Програма «Каталог вакансій для ІТ-спеціалістів» (варіант 13).
///
/// `@main` — з цієї структури програма починається. Стан вікна (`CatalogViewModel`) створюється тут один раз,
/// щоб і вікно, і головне меню (крок 4.12) працювали з тим самим каталогом.
@main
struct VacancyCatalogApp: App {

    /// Стан головного вікна. `@State` — SwiftUI зберігає об'єкт, поки працює програма.
    @State private var viewModel = CatalogViewModel()

    var body: some Scene {
        // Window, а не WindowGroup: у програми одне вікно і один каталог
        Window("Каталог вакансій", id: "main") {
            MainWindowView(viewModel: viewModel)
        }
        .defaultSize(width: 1440, height: 900)
    }
}
