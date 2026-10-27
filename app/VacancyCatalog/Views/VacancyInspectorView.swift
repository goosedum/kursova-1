//
//  VacancyInspectorView.swift
//  Панель деталей праворуч: одна вибрана вакансія, кілька вибраних або підказка «виберіть вакансію».
//

import SwiftUI

/// Панель деталей (Figma: `Organism/Inspector`, екрани S-02 і S-18a; прецедент UC-06).
///
/// Одна вибрана вакансія — усі поля, зарплата з середньою і діапазоном, технології, кнопки «Редагувати» і
/// «Дублювати». Кілька вибраних — їхній список і «Видалити вибрані» (D-25). Нічого не вибрано — підказка.
struct VacancyInspectorView: View {

    /// Стан вікна.
    let viewModel: CatalogViewModel

    var body: some View {
        let selected = viewModel.selectedVacancies
        if selected.count == 1 {
            details(of: selected[0])
        } else if selected.count > 1 {
            summary(of: selected)
        } else {
            ContentUnavailableView("Нічого не вибрано", systemImage: "info.circle",
                                   description: Text("Виберіть вакансію, щоб побачити деталі."))
        }
    }

    /// Деталі однієї вакансії.
    private func details(of vacancy: Vacancy) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(vacancy.title)
                        .font(.headline)
                    Text(vacancy.company)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: AppSpacing.xs) {
                    LevelBadge(level: vacancy.experienceLevel)
                    FormatBadge(format: vacancy.workFormat)
                }
                Divider()
                SalaryRangeView(vacancy: vacancy, showsDetails: true)
                InspectorField(label: "Спеціалізація", value: vacancy.specialization)
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Технології")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TechnologyList(technologies: vacancy.technologies, highlighted: viewModel.highlightedTechnology)
                }
                Divider()
                HStack(spacing: AppSpacing.s) {
                    Button("Редагувати") {
                        viewModel.editSelected()
                    }
                    .help("Змінити вакансію (⌘E)")
                    Button("Дублювати") {
                        viewModel.duplicateSelected()
                    }
                    .help("Створити копію вакансії одразу під нею (⌘D)")
                }
            }
            .padding(AppSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Кілька вибраних вакансій: список і кнопка «Видалити вибрані».
    private func summary(of vacancies: [Vacancy]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                Text("Вибрано " + TextFormat.count(vacancies.count, one: "вакансію", few: "вакансії", many: "вакансій"))
                    .font(.headline)
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(vacancies) { vacancy in
                        Text("• \(vacancy.title) — \(vacancy.company)")
                    }
                }
                Text("Редагувати й дублювати можна лише одну вакансію. Видалити можна всі вибрані разом.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("Видалити вибрані", role: .destructive) {
                    viewModel.isDeleteConfirmationPresented = true
                }
                .help("Видалити всі вибрані вакансії (⌘⌫)")
            }
            .padding(AppSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
