//
//  ExperienceLevelTests.swift
//  Тести переліку ExperienceLevel: ключі для файлу, порядок рівнів.
//

import Testing
@testable import VacancyCatalog

/// Тести переліку `ExperienceLevel`.
@MainActor
struct ExperienceLevelTests {

    @Test("Ключі для файлу — англійською (D-22) і читаються назад")
    func rawValuesRoundTrip() {
        #expect(ExperienceLevel.junior.rawValue == "Junior")
        #expect(ExperienceLevel(rawValue: "Lead") == .lead)
        #expect(ExperienceLevel(rawValue: "Pro") == nil)
    }

    @Test("Рівні впорядковані: Intern < Junior < Middle < Senior < Lead")
    func levelsAreOrdered() {
        let levels = ExperienceLevel.allCases
        #expect(levels.count == 5)
        for index in 1..<levels.count {
            #expect(levels[index - 1].order < levels[index].order)
        }
    }
}
