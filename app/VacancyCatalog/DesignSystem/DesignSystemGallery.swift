//
//  DesignSystemGallery.swift
//  Вітрина дизайн-системи: усі атоми й молекули на одному екрані — для порівняння з Figma (крок 4.8, звіт).
//

import SwiftUI

/// Усі елементи дизайн-системи поруч, як сторінки `02 Atoms` і `03 Molecules` у Figma.
/// У програмі не показується — лише в Preview і на знімках для звіту.
struct DesignSystemGallery: View {

    /// Перша вакансія демо-файлу — для зарплати і технологій.
    private let vacancy = Vacancy(company: "ByteForge", title: "Junior iOS Developer", specialization: "Mobile",
                                  experienceLevel: .junior, minSalary: 800, maxSalary: 1200, workFormat: .office,
                                  technologies: ["Swift", "UIKit", "Git"])

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            section("LevelBadge") {
                HStack(spacing: AppSpacing.s) {
                    ForEach(ExperienceLevel.allCases) { level in
                        LevelBadge(level: level)
                    }
                }
            }
            section("FormatBadge") {
                HStack(spacing: AppSpacing.s) {
                    ForEach(WorkFormat.allCases) { format in
                        FormatBadge(format: format)
                    }
                }
            }
            section("TechnologyChip · TechnologyList") {
                HStack(spacing: AppSpacing.xxxl) {
                    HStack(spacing: AppSpacing.s) {
                        TechnologyChip(name: "Swift")
                        TechnologyChip(name: "Swift", isHighlighted: true)
                    }
                    TechnologyList(technologies: ["Swift", "SwiftUI", "Combine", "Git", "Xcode", "Core Data"],
                                   highlighted: "Swift")
                        .frame(width: 200, alignment: .leading)
                }
            }
            section("SalaryRangeView") {
                HStack(alignment: .top, spacing: AppSpacing.xxxl) {
                    SalaryRangeView(vacancy: vacancy)
                    SalaryRangeView(vacancy: vacancy, showsDetails: true)
                }
            }
            section("FieldLabel · FieldErrorText · InspectorField") {
                HStack(alignment: .top, spacing: AppSpacing.xxxl) {
                    FieldLabel(text: "Компанія")
                    FieldErrorText(message: "Поле «Компанія» не може бути порожнім.")
                    InspectorField(label: "Компанія", value: "ByteForge")
                }
            }
            section("ResultGroupHeader") {
                HStack(alignment: .top, spacing: AppSpacing.xxxl) {
                    ResultGroupHeader(group: VacancyGroup(title: "Mobile", vacancies: [vacancy]))
                    ResultGroupHeader(group: VacancyGroup(title: "Найменший діапазон", subtitle: "макс − мін = $300",
                                                          vacancies: [vacancy, vacancy, vacancy]))
                }
            }
        }
        .padding(AppSpacing.xxl)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    /// Розділ вітрини: сірий заголовок і вміст під ним.
    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            content()
        }
    }
}

#Preview("Світла тема") {
    DesignSystemGallery()
}

#Preview("Темна тема") {
    DesignSystemGallery()
        .preferredColorScheme(.dark)
}
