//
//  ExperienceLevel.swift
//  Рівень досвіду, якого вимагає вакансія (Intern … Lead).
//

import Foundation

/// Рівень досвіду кандидата, якого вимагає вакансія.
///
/// `rawValue` — англійський ключ, який записується у файл (рішення D-22), `title` — назва в інтерфейсі.
/// Рівні впорядковані: їх можна порівнювати за `order` (Intern < Junior < Middle < Senior < Lead).
enum ExperienceLevel: String, CaseIterable, Identifiable {
    /// Стажер — без досвіду, навчання на проєкті.
    case intern = "Intern"
    /// Молодший спеціаліст — до 1–2 років досвіду.
    case junior = "Junior"
    /// Спеціаліст середнього рівня — самостійно виконує задачі.
    case middle = "Middle"
    /// Старший спеціаліст — ухвалює технічні рішення, навчає інших.
    case senior = "Senior"
    /// Керівник команди або напряму.
    case lead = "Lead"

    /// Ідентифікатор для списків SwiftUI — збігається з ключем у файлі.
    var id: String {
        return rawValue
    }

    /// Назва рівня в інтерфейсі (у ІТ ці назви не перекладають).
    var title: String {
        return rawValue
    }

    /// Порядковий номер рівня: 1 — Intern, …, 5 — Lead.
    var order: Int {
        switch self {
        case .intern:
            return 1
        case .junior:
            return 2
        case .middle:
            return 3
        case .senior:
            return 4
        case .lead:
            return 5
        }
    }
}
