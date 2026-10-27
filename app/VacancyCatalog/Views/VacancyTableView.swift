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

            TableColumn("Середня") { vacancy in
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
        // Подвійний клік по рядку — редагувати (UC-08). Пункти контекстного меню додає крок 4.12.
        .contextMenu(forSelectionType: UUID.self) { _ in
        } primaryAction: { clickedIDs in
            viewModel.selectedVacancyIDs = clickedIDs
            viewModel.editSelected()
        }
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
