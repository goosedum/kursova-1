//
//  WorkFormatTests.swift
//  Тести переліку WorkFormat: ключі для файлу, назви в інтерфейсі.
//

import Testing
@testable import VacancyCatalog

/// Тести переліку `WorkFormat`.
@MainActor
struct WorkFormatTests {

    @Test("Ключі для файлу — англійською (D-22) і читаються назад")
    func rawValuesRoundTrip() {
        #expect(WorkFormat.remote.rawValue == "Remote")
        #expect(WorkFormat(rawValue: "Hybrid") == .hybrid)
        #expect(WorkFormat(rawValue: "Офіс") == nil)
    }

    @Test("Назви в інтерфейсі — українською")
    func titlesAreUkrainian() {
        #expect(WorkFormat.office.title == "Офіс")
        #expect(WorkFormat.remote.title == "Віддалено")
        #expect(WorkFormat.hybrid.title == "Гібрид")
    }
}
