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
            Text(format.title)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.format(format).opacity(AppColor.badgeTintOpacity), in: Capsule())
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
