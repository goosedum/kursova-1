//
//  SalaryRangeView.swift
//  Молекула «зарплата»: «$800 – $1 200»; детальна — ще середня і діапазон.
//

import SwiftUI

/// Зарплата вакансії (Figma: `Molecule/SalaryRange`).
///
/// Звичайна — один рядок «$800 – $1 200» (таблиця). Детальна (`showsDetails`) — більший шрифт і другий рядок
/// «середня $1 000 · діапазон $400» (панель деталей).
struct SalaryRangeView: View {

    /// Вакансія, зарплату якої показуємо.
    let vacancy: Vacancy
    /// Чи показати середню зарплату і діапазон.
    var showsDetails = false

    var body: some View {
        if showsDetails {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(rangeText)
                    .font(.title3.weight(.semibold))
                Text("середня " + TextFormat.money(vacancy.averageSalary)
                     + " · діапазон " + TextFormat.money(vacancy.salaryRange))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .monospacedDigit()
        } else {
            Text(rangeText)
                .monospacedDigit()
        }
    }

    /// «$800 – $1 200».
    private var rangeText: String {
        return TextFormat.money(vacancy.minSalary) + " – " + TextFormat.money(vacancy.maxSalary)
    }
}

#Preview("SalaryRangeView") {
    let vacancy = Vacancy(company: "ByteForge", title: "Junior iOS Developer", specialization: "Mobile",
                          experienceLevel: .junior, minSalary: 800, maxSalary: 1200, workFormat: .office,
                          technologies: ["Swift"])
    HStack(spacing: AppSpacing.xxxl) {
        SalaryRangeView(vacancy: vacancy)
        SalaryRangeView(vacancy: vacancy, showsDetails: true)
    }
    .padding()
}
