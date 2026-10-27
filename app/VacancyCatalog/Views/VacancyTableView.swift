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
            .width(min: 80, ideal: 100)

            TableColumn("Посада") { vacancy in
                Text(vacancy.title)
                    .fontWeight(.semibold)
            }
            .width(min: 140, ideal: 190)

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
            .width(min: 100, ideal: 115)

            TableColumn(viewModel.averageColumnTitle) { vacancy in
                Text(TextFormat.money(vacancy.averageSalary))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .width(min: 60, ideal: 70)

            TableColumn("Технології") { vacancy in
                // В один рядок; що не вміщується — обрізається краєм колонки (усі — у панелі деталей)
                HStack(spacing: AppSpacing.xs) {
                    ForEach(vacancy.technologies, id: \.self) { technology in
                        TechnologyChip(name: technology, isHighlighted: isHighlighted(technology))
                    }
                }
            }
            .width(min: 120, ideal: 220)
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

    /// Чи виділити чип: технологія збігається із запитом ф.2 (без урахування регістру).
    private func isHighlighted(_ technology: String) -> Bool {
        let query = viewModel.highlightedTechnology.trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            return false
        }
        return technology.lowercased() == query.lowercased()
    }
}
