//
//  EmptyStateView.swift
//  Порожній стан каталогу: поради і три кнопки — відкрити файл, додати вакансію, демо-дані.
//

import SwiftUI

/// Порожній каталог (Figma: `Molecule/EmptyState`, kind = emptyCatalog; екран S-01; прецедент UC-05, A1).
///
/// `ContentUnavailableView` — системний вигляд «тут поки нічого немає»: іконка, заголовок, пояснення, кнопки.
struct EmptyStateView: View {

    /// Стан вікна.
    let viewModel: CatalogViewModel

    var body: some View {
        ContentUnavailableView {
            Label("Каталог порожній", systemImage: "tray")
        } description: {
            Text("Відкрийте файл із вакансіями, додайте вакансію вручну або завантажте демо-дані, "
                 + "щоб спробувати функції 1–6.")
        } actions: {
            HStack(spacing: AppSpacing.s) {
                Button("Відкрити файл…") {
                    viewModel.requestOpen()
                }
                .buttonStyle(.borderedProminent)
                .help("Відкрити каталог з текстового файлу (⌘O)")
                Button("Додати вакансію") {
                    viewModel.newVacancy()
                }
                .help("Додати вакансію вручну (⌘N)")
                Button("Демо-дані") {
                    viewModel.requestDemoData()
                }
                .buttonStyle(.link)
                .help("Відкрити вбудований каталог з 28 вакансій")
            }
        }
    }
}
