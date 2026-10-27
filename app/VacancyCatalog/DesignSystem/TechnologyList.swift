//
//  TechnologyList.swift
//  Молекула «перелік технологій»: чипи з переносом на новий рядок.
//

import SwiftUI

/// Технології вакансії чипами з переносом рядка (Figma: `Molecule/TechnologyList`).
struct TechnologyList: View {

    /// Технології вакансії.
    let technologies: [String]
    /// Технологія, яку виділити (пошук ф.2); порожньо — нічого не виділяти.
    var highlighted = ""

    var body: some View {
        FlowLayout(spacing: AppSpacing.xs) {
            // id: \.self — кожен чип розрізняємо за назвою (повтори прибирає Vacancy.normalize())
            ForEach(technologies, id: \.self) { technology in
                TechnologyChip(name: technology, isHighlighted: isHighlighted(technology))
            }
        }
    }

    /// Чи збігається технологія з пошуком (без регістру, як у ф.2).
    private func isHighlighted(_ technology: String) -> Bool {
        let query = highlighted.trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            return false
        }
        return technology.lowercased() == query.lowercased()
    }
}

#Preview("TechnologyList") {
    TechnologyList(technologies: ["Swift", "SwiftUI", "Combine", "Git", "Xcode", "Core Data", "Figma"],
                   highlighted: "swift")
        .frame(width: 240, alignment: .leading)
        .padding()
}
