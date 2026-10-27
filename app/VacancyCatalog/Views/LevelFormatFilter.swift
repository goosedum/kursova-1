//
//  LevelFormatFilter.swift
//  Параметри функції 3: списки «Рівень досвіду» і «Формат роботи».
//

import SwiftUI

/// Два списки функції 3 (Figma: `Molecule/LevelFormatFilter`, екран S-05). Значення лише зі списку — помилок немає.
/// Новий вибір одразу показує результат (`onChange`).
struct LevelFormatFilter: View {

    /// Функція 3.
    @Bindable var operation: FilterByLevelAndFormatOperation
    /// Що зробити, коли вибрали інше значення.
    let onChange: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: AppSpacing.m) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                FieldLabel(text: "Рівень досвіду")
                Picker("Рівень досвіду", selection: $operation.level) {
                    ForEach(ExperienceLevel.allCases) { level in
                        Text(level.title)
                            .tag(level)
                    }
                }
                .labelsHidden()
                .fixedSize()
            }
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                FieldLabel(text: "Формат роботи")
                Picker("Формат роботи", selection: $operation.format) {
                    ForEach(WorkFormat.allCases) { format in
                        Text(format.title)
                            .tag(format)
                    }
                }
                .labelsHidden()
                .fixedSize()
            }
        }
        .onChange(of: operation.level) {
            onChange()
        }
        .onChange(of: operation.format) {
            onChange()
        }
    }
}
