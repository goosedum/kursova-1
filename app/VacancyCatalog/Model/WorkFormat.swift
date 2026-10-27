//
//  WorkFormat.swift
//  Формат роботи за вакансією: офіс, віддалено або гібрид.
//

import Foundation

/// Формат роботи за вакансією.
///
/// `rawValue` — англійський ключ, який записується у файл (рішення D-22), `title` — назва в інтерфейсі,
/// `systemImage` — назва іконки SF Symbols (див. `docs/design/icons.md`).
enum WorkFormat: String, CaseIterable, Identifiable {
    case office = "Office"
    case remote = "Remote"
    case hybrid = "Hybrid"

    /// Ідентифікатор для списків SwiftUI — збігається з ключем у файлі.
    var id: String {
        return rawValue
    }

    /// Назва формату в інтерфейсі.
    var title: String {
        switch self {
        case .office:
            return "Офіс"
        case .remote:
            return "Віддалено"
        case .hybrid:
            return "Гібрид"
        }
    }

    /// Назва іконки SF Symbols для бейджа формату.
    var systemImage: String {
        switch self {
        case .office:
            return "briefcase"
        case .remote:
            return "laptopcomputer"
        case .hybrid:
            return "arrow.triangle.swap"
        }
    }
}
