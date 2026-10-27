//
//  TextFormat.swift
//  Українські тексти з числами: «3 вакансії», «5 вакансій», суми «$3 000».
//

import Foundation

/// Допоміжні функції для текстів з числами. Це `enum` без випадків: створити його об'єкт не можна,
/// він лише збирає разом статичні функції (як клас зі статичними методами в C++).
enum TextFormat {

    /// Число разом зі словом у правильній формі: 1 вакансія, 2 вакансії, 5 вакансій, 11 вакансій, 21 вакансія.
    ///
    /// - Parameters:
    ///   - one: Форма для 1, 21, 31… («вакансія»).
    ///   - few: Форма для 2–4, 22–24… («вакансії»).
    ///   - many: Форма для 0, 5–20, 25–30… («вакансій»).
    static func count(_ number: Int, one: String, few: String, many: String) -> String {
        let lastTwoDigits = number % 100
        let lastDigit = number % 10
        var word = many
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            word = many
        } else if lastDigit == 1 {
            word = one
        } else if lastDigit >= 2 && lastDigit <= 4 {
            word = few
        }
        return "\(number) \(word)"
    }

    /// «1 вакансія», «3 вакансії», «28 вакансій».
    static func vacancies(_ number: Int) -> String {
        return count(number, one: "вакансія", few: "вакансії", many: "вакансій")
    }

    /// Сума в доларах із пробілом між тисячами: 300 → «$300», 3000 → «$3 000».
    static func money(_ amount: Int) -> String {
        let digits = String(amount)
        var result = ""
        var digitCount = 0
        // Ідемо з кінця числа і перед кожною трійкою цифр ставимо пробіл
        for digit in digits.reversed() {
            if digitCount > 0 && digitCount % 3 == 0 {
                result = " " + result
            }
            result = String(digit) + result
            digitCount += 1
        }
        return "$" + result
    }
}
