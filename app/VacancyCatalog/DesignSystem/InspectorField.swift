//
//  InspectorField.swift
//  Молекула «поле панелі деталей»: сірий підпис і значення під ним.
//

import SwiftUI

/// Підпис і значення в панелі деталей (Figma: `Molecule/InspectorField`): «Компанія» / «ByteForge».
struct InspectorField: View {

    /// Назва поля.
    let label: String
    /// Значення поля.
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
        }
    }
}

#Preview("InspectorField") {
    InspectorField(label: "Компанія", value: "ByteForge")
        .padding()
}
