//
//  FormatBadge.swift
//  Атом «бейдж формату роботи»: іконка SF Symbols і назва на тлі кольору формату.
//

import SwiftUI

/// Бейдж формату роботи (Figma: `Atom/FormatBadge`).
///
/// «Пігулка» з тлом кольору формату (16%), іконкою цього ж кольору і назвою: 💼 Офіс.
struct FormatBadge: View {

    /// Формат, який показує бейдж.
    let format: WorkFormat

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: format.systemImage)
                .foregroundStyle(AppColor.format(format))
                // Іконка лише прикраса: без цього VoiceOver прочитав би англійську назву символу («briefcase»)
                .accessibilityHidden(true)
            Text(format.title)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.format(format).opacity(AppColor.badgeTintOpacity), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Формат \(format.title)")
    }
}

#Preview("FormatBadge") {
    HStack {
        ForEach(WorkFormat.allCases) { format in
            FormatBadge(format: format)
        }
    }
    .padding()
}
