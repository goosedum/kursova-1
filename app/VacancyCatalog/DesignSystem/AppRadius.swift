//
//  AppRadius.swift
//  Радіуси заокруглення — ті самі значення, що й змінні Radius у Figma.
//

import SwiftUI

/// Радіуси кутів (колекція `Radius` у Figma). Для «пігулки» (бейджі) замість числа — форма `Capsule()`.
///
/// Концентричність: радіус внутрішнього елемента = радіус зовнішнього − відступ між ними.
enum AppRadius {
    /// 6 pt — чип технології, кнопка, поле.
    static let s: CGFloat = 6
    /// 10 pt.
    static let m: CGFloat = 10
    /// 14 pt.
    static let l: CGFloat = 14
    /// 20 pt — лист (форма), алерт.
    static let xl: CGFloat = 20
}
