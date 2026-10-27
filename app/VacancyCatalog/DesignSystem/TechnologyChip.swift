//
//  TechnologyChip.swift
//  Атом «чип технології»: назва технології в сірому прямокутнику; виділений — синя рамка.
//

import SwiftUI

/// Чип технології (Figma: `Atom/TechnologyChip`).
///
/// Звичайний — сіре тло; виділений (`isHighlighted`) — тло й рамка кольору акценту: так у результаті ф.2 видно,
/// за якою технологією знайдено вакансію.
struct TechnologyChip: View {

    /// Назва технології.
    let name: String
    /// Чи збігається технологія з пошуком (ф.2).
    var isHighlighted = false

    var body: some View {
        Text(name)
            .font(.subheadline)
            .padding(.horizontal, AppSpacing.s)
            .padding(.vertical, AppSpacing.xxs)
            .background(fill, in: RoundedRectangle(cornerRadius: AppRadius.s))
            .overlay {
                if isHighlighted {
                    RoundedRectangle(cornerRadius: AppRadius.s)
                        .stroke(Color.accentColor, lineWidth: 1)
                }
            }
    }

    /// Колір тла: сірий або напівпрозорий акцент для виділеного чипа.
    private var fill: Color {
        if isHighlighted {
            return Color.accentColor.opacity(AppColor.highlightTintOpacity)
        }
        return AppColor.chipBackground
    }
}

#Preview("TechnologyChip") {
    HStack {
        TechnologyChip(name: "Swift")
        TechnologyChip(name: "Swift", isHighlighted: true)
    }
    .padding()
}
