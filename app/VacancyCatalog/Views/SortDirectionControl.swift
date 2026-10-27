//
//  SortDirectionControl.swift
//  Параметр функції 4: напрям сортування ↓ / ↑.
//

import SwiftUI

/// Перемикач напряму функції 4 (Figma: `Molecule/SortDirectionControl`, екран S-06). За замовчуванням — за
/// спаданням (D-11). Новий напрям одразу показує результат (`onChange`).
struct SortDirectionControl: View {

    /// Функція 4.
    @Bindable var operation: SortByAverageSalaryOperation
    /// Що зробити, коли змінили напрям.
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            FieldLabel(text: "Напрям")
            HStack(spacing: AppSpacing.s) {
                Picker("Напрям", selection: $operation.ascending) {
                    // accessibilityLabel — що прочитає VoiceOver замість назви символу «arrow.down»
                    Image(systemName: "arrow.down")
                        .accessibilityLabel("За спаданням")
                        .help("За спаданням")
                        .tag(false)
                    Image(systemName: "arrow.up")
                        .accessibilityLabel("За зростанням")
                        .help("За зростанням")
                        .tag(true)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
                Text(directionText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .onChange(of: operation.ascending) {
            onChange()
        }
    }

    /// Підпис поруч із перемикачем.
    private var directionText: String {
        if operation.ascending {
            return "за зростанням"
        }
        return "за спаданням (за замовчуванням)"
    }
}
