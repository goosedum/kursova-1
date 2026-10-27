//
//  NothingFoundView.swift
//  Порожній результат функції: «Нічого не знайдено» і кнопка «Показати всі вакансії».
//

import SwiftUI

/// Функція нічого не знайшла (Figma: `Molecule/EmptyState`, kind = noResults; прецедент UC-11, A1).
struct NothingFoundView: View {

    /// Стан вікна.
    let viewModel: CatalogViewModel

    var body: some View {
        ContentUnavailableView {
            Label("Нічого не знайдено", systemImage: "magnifyingglass")
        } description: {
            Text("Змініть параметри функції або поверніться до всіх вакансій.")
        } actions: {
            Button("Показати всі вакансії") {
                viewModel.showAll()
            }
        }
    }
}
