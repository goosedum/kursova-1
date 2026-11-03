//
//  TechnologyRow.swift
//  Молекула «технології в один рядок»: цілі чипи, що вміщуються, і «+N» замість решти (D-40).
//

import SwiftUI

/// Технології вакансії в один рядок для таблиці (D-40, дефект Ф-1).
///
/// Показує стільки **цілих** чипів, скільки вміщується в ширину колонки, а замість решти — «+N».
/// `ViewThatFits` пробує варіанти по черзі (усі чипи, на один менше, …, один) і бере перший, що вміщується.
/// Усі технології видно в панелі деталей.
struct TechnologyRow: View {

    /// Технології вакансії.
    let technologies: [String]
    /// Технологія, яку виділити (пошук ф.2); порожньо — нічого не виділяти.
    var highlighted = ""

    var body: some View {
        ViewThatFits(in: .horizontal) {
            // id: \.self — варіанти розрізняємо за кількістю показаних чипів
            ForEach(chipCounts, id: \.self) { count in
                row(showing: count)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }

    /// Скільки чипів показати в кожному варіанті: N, N − 1, …, 1 (для порожнього переліку — 0).
    private var chipCounts: [Int] {
        var counts: [Int] = []
        var count = technologies.count
        while count >= 1 {
            counts.append(count)
            count -= 1
        }
        if counts.isEmpty {
            counts.append(0)
        }
        return counts
    }

    /// Перші `count` чипів і, якщо щось не показано, позначка «+N».
    private func row(showing count: Int) -> some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<count, id: \.self) { index in
                TechnologyChip(name: technologies[index], isHighlighted: isHighlighted(technologies[index]))
            }
            if count < technologies.count {
                Text("+\(technologies.count - count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("і ще \(technologies.count - count)")
            }
        }
        // Чипи не стискаються: варіант або вміщується цілим, або ViewThatFits бере наступний
        .fixedSize()
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

#Preview("TechnologyRow") {
    VStack(alignment: .leading, spacing: AppSpacing.s) {
        TechnologyRow(technologies: ["Python", "Django", "PostgreSQL", "Docker", "AWS"])
            .frame(width: 330)
        TechnologyRow(technologies: ["Python", "Django", "PostgreSQL", "Docker", "AWS"])
            .frame(width: 220)
        TechnologyRow(technologies: ["Swift", "SwiftUI", "Combine", "Git"], highlighted: "swiftui")
            .frame(width: 140)
    }
    .padding()
}
