//
//  LevelBadge.swift
//  Атом «бейдж рівня досвіду»: кольорова крапка і назва рівня на тлі кольору рівня.
//

import SwiftUI

/// Бейдж рівня досвіду (Figma: `Atom/LevelBadge`).
///
/// «Пігулка» з тлом кольору рівня (16%), крапкою 6 pt і назвою: ● Junior.
struct LevelBadge: View {

    /// Рівень, який показує бейдж.
    let level: ExperienceLevel

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Circle()
                .fill(AppColor.level(level))
                .frame(width: 6, height: 6)
            Text(level.title)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.level(level).opacity(AppColor.badgeTintOpacity), in: Capsule())
        // VoiceOver читає бейдж одним реченням: «Рівень Junior»
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Рівень \(level.title)")
    }
}

#Preview("LevelBadge") {
    HStack {
        ForEach(ExperienceLevel.allCases) { level in
            LevelBadge(level: level)
        }
    }
    .padding()
}
