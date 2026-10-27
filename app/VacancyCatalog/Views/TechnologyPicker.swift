//
//  TechnologyPicker.swift
//  Параметр функції 2: поле технології з підказками зі списку технологій каталогу.
//

import SwiftUI

/// Поле функції 2 (Figma: `Molecule/TechnologyPicker`, екран S-04): під час введення підказує технології каталогу (D-10).
struct TechnologyPicker: View {

    /// Функція 2.
    @Bindable var operation: SearchByTechnologyOperation
    /// Усі технології каталогу для підказок (`VacancyCatalog.allTechnologies`).
    let technologies: [String]
    /// Що зробити, коли в полі натиснули ⏎.
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            FieldLabel(text: "Технологія")
            TextField("Наприклад, Swift", text: $operation.technology)
                .frame(width: 180)
                .textInputSuggestions {
                    ForEach(technologies, id: \.self) { technology in
                        Text(technology)
                            .textInputCompletion(technology)
                    }
                }
                .onSubmit(onSubmit)
        }
    }
}
