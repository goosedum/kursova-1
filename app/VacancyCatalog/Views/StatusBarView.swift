//
//  StatusBarView.swift
//  Рядок стану внизу вікна: що показано і чи збережено зміни.
//

import SwiftUI

/// Рядок стану (Figma: `Organism/StatusBar`): ліворуч «28 вакансій · vacancies.txt», праворуч
/// «Усі зміни збережено» (зелена позначка) або «Є незбережені зміни» (помаранчева, D-24).
struct StatusBarView: View {

    /// Стан вікна.
    let viewModel: CatalogViewModel

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Text(viewModel.statusText)
                Spacer()
                if viewModel.hasUnsavedChanges {
                    Label {
                        Text("Є незбережені зміни")
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(AppColor.warning)
                    }
                } else {
                    Label {
                        Text("Усі зміни збережено")
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColor.success)
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, AppSpacing.l)
            .frame(height: 28)
        }
        .background(.bar)
    }
}
