//
//  AppColor.swift
//  Кольори дизайн-системи: кожен токен Figma — системний колір Apple, тому світла й темна теми працюють самі.
//

import SwiftUI

/// Кольори застосунку (колекція `Color` у Figma).
///
/// У Figma кожен токен — посилання на системний колір Apple (рішення D-28), тому тут ті самі системні кольори
/// SwiftUI: вони самі змінюються в темній темі й у режимі підвищеного контрасту.
/// Кольори тексту окремо не задаємо — це стандартні `.primary` (85%) і `.secondary` (50%).
enum AppColor {

    /// Прозорість кольорового тла бейджа рівня чи формату (16% у Figma).
    static let badgeTintOpacity = 0.16
    /// Прозорість тла виділеного чипа технології (14% у Figma).
    static let highlightTintOpacity = 0.14

    /// Тло чипа технології (`chip/bg`: 5% кольору тексту).
    static let chipBackground = Color(nsColor: .quinaryLabelColor)
    /// Колір помилки (`status/danger`).
    static let danger = Color.red
    /// Колір успіху (`status/success`) — «Усі зміни збережено».
    static let success = Color.green
    /// Колір попередження (`status/warning`) — «Є незбережені зміни».
    static let warning = Color.orange

    /// Колір рівня досвіду: Intern — сірий, Junior — зелений, Middle — синій, Senior — індиго, Lead — фіолетовий.
    static func level(_ level: ExperienceLevel) -> Color {
        switch level {
        case .intern:
            return .gray
        case .junior:
            return .green
        case .middle:
            return .blue
        case .senior:
            return .indigo
        case .lead:
            return .purple
        }
    }

    /// Колір формату роботи: Офіс — помаранчевий, Віддалено — бірюзовий, Гібрид — рожевий.
    static func format(_ format: WorkFormat) -> Color {
        switch format {
        case .office:
            return .orange
        case .remote:
            return .teal
        case .hybrid:
            return .pink
        }
    }
}
