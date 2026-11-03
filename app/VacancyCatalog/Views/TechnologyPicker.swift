//
//  TechnologyPicker.swift
//  Параметр функції 2: поле технології з підказками зі списку технологій каталогу.
//

import SwiftUI

/// Поле функції 2 (Figma: `Molecule/TechnologyPicker`, екран S-04): під час введення підказує технології каталогу,
/// що містять уведений текст (D-10, Ф-3).
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
                    // Лише ті, що містять уведений текст (Ф-3)
                    ForEach(operation.suggestions(from: technologies), id: \.self) { technology in
                        Text(technology)
                            .textInputCompletion(technology)
                    }
                }
                .onSubmit(onSubmit)
        }
    }
}

#Preview("TechnologyPicker") {
    TechnologyPicker(operation: SearchByTechnologyOperation(), technologies: ["Docker", "Git", "Swift", "SwiftUI"],
                     onSubmit: {})
        .padding()
}
