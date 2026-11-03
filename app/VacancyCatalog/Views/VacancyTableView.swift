//
//  VacancyTableView.swift
//  Таблиця вакансій: 8 колонок, вибір кількох рядків, групи з заголовками для ф.5 і ф.6.
//

import SwiftUI

/// Таблиця вакансій (Figma: `Organism/VacancyTable`).
///
/// `Table` — системна таблиця macOS: заголовки колонок, смуги рядків, вибір кількох рядків ⌘/⇧-кліком (D-25).
/// Рядки — `viewModel.displayedGroups`: весь каталог або результат функції; група із заголовком — розділ таблиці.
struct VacancyTableView: View {

    /// Стан вікна.
    @Bindable var viewModel: CatalogViewModel

    var body: some View {
        Table(of: Vacancy.self, selection: $viewModel.selectedVacancyIDs) {
            TableColumn("Компанія") { vacancy in
                Text(vacancy.company)
            }
            .width(min: 70, ideal: 100)

            TableColumn("Посада") { vacancy in
                Text(vacancy.title)
                    .fontWeight(.semibold)
            }
            // Посада може обрізатися «…» (повна — у панелі деталей); зарплата й технології — ні (Ф-1)
            .width(min: 100, ideal: 190)

            TableColumn("Спеціалізація") { vacancy in
                Text(vacancy.specialization)
                    .foregroundStyle(.secondary)
            }
            .width(min: 80, ideal: 100)

            TableColumn("Рівень") { vacancy in
                LevelBadge(level: vacancy.experienceLevel)
            }
            .width(90)

            TableColumn("Формат") { vacancy in
                FormatBadge(format: vacancy.workFormat)
            }
            .width(115)

            TableColumn("Зарплата") { vacancy in
                SalaryRangeView(vacancy: vacancy)
            }
            // min — щоб «$5 000 – $8 000» вміщувалася й тоді, коли відкрито панель деталей (Ф-1)
            .width(min: 125, ideal: 130)

            TableColumn(viewModel.averageColumnTitle) { vacancy in
                Text(TextFormat.money(vacancy.averageSalary))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .width(min: 60, ideal: 70)

            TableColumn("Технології") { vacancy in
                // В один рядок: цілі чипи, що вміщуються, і «+N» (D-40); усі — у панелі деталей
                TechnologyRow(technologies: vacancy.technologies, highlighted: viewModel.highlightedTechnology)
            }
            .width(min: 100, ideal: 220)
        } rows: {
            ForEach(viewModel.displayedGroups) { group in
                if group.title.isEmpty {
                    ForEach(group.vacancies) { vacancy in
                        TableRow(vacancy)
                    }
                } else {
                    Section {
                        ForEach(group.vacancies) { vacancy in
                            TableRow(vacancy)
                        }
                    } header: {
                        ResultGroupHeader(group: group)
                    }
                }
            }
        }
        // Права кнопка миші — контекстне меню (S-12); подвійний клік — редагувати (UC-08).
        // clickedIDs — рядки, на яких клацнули: вибрані, або лише цей рядок, якщо він не вибраний (UC-10, A2)
        .contextMenu(forSelectionType: UUID.self) { clickedIDs in
            rowMenu(for: clickedIDs)
        } primaryAction: { clickedIDs in
            viewModel.selectedVacancyIDs = clickedIDs
            viewModel.editSelected()
        }
    }

    /// Пункти контекстного меню для рядків `clickedIDs`.
    @ViewBuilder
    private func rowMenu(for clickedIDs: Set<UUID>) -> some View {
        let clicked = vacancies(with: clickedIDs)
        Button {
            viewModel.selectedVacancyIDs = clickedIDs
            viewModel.editSelected()
        } label: {
            Label("Редагувати…", systemImage: "pencil")
        }
        .disabled(clicked.count != 1)
        Button {
            viewModel.selectedVacancyIDs = clickedIDs
            viewModel.duplicateSelected()
        } label: {
            Label("Дублювати", systemImage: "square.on.square")
        }
        .disabled(clicked.count != 1)

        if clicked.count == 1 {
            Divider()
            Menu {
                ForEach(clicked[0].technologies, id: \.self) { technology in
                    Button(technology) {
                        viewModel.findVacancies(withTechnology: technology)
                    }
                }
            } label: {
                Label("Знайти за технологією", systemImage: "cpu")
            }
            Button {
                viewModel.findVacancies(ofCompany: clicked[0].company)
            } label: {
                Label("Вакансії компанії «\(clicked[0].company)»", systemImage: "magnifyingglass")
            }
        }

        Divider()
        Button(role: .destructive) {
            viewModel.selectedVacancyIDs = clickedIDs
            viewModel.isDeleteConfirmationPresented = true
        } label: {
            Label(deleteTitle(count: clicked.count), systemImage: "trash")
        }
        .disabled(clicked.isEmpty)
    }

    /// «Видалити» для однієї вакансії, «Видалити 3 вакансії» для кількох.
    private func deleteTitle(count: Int) -> String {
        if count > 1 {
            return "Видалити " + TextFormat.count(count, one: "вакансію", few: "вакансії", many: "вакансій")
        }
        return "Видалити"
    }

    /// Вакансії каталогу з указаними ID (у порядку каталогу).
    private func vacancies(with ids: Set<UUID>) -> [Vacancy] {
        var found: [Vacancy] = []
        for vacancy in viewModel.catalog.vacancies {
            if ids.contains(vacancy.id) {
                found.append(vacancy)
            }
        }
        return found
    }
}

#Preview("Усі вакансії") {
    let viewModel = CatalogViewModel()
    viewModel.loadDemoData()
    return VacancyTableView(viewModel: viewModel)
        .frame(width: 1100, height: 600)
}

#Preview("Ф.5 — дві групи") {
    let viewModel = CatalogViewModel()
    viewModel.loadDemoData()
    viewModel.run(viewModel.operations[4])
    return VacancyTableView(viewModel: viewModel)
        .frame(width: 1100, height: 400)
}

#Preview("Ф.2 — виділена технологія") {
    let viewModel = CatalogViewModel()
    viewModel.loadDemoData()
    viewModel.findVacancies(withTechnology: "Swift")
    return VacancyTableView(viewModel: viewModel)
        .frame(width: 1100, height: 300)
}
