//
//  HelpTopicTests.swift
//  Тести розділів довідки: кожен розділ має назву, іконку і текст.
//

import Testing
@testable import VacancyCatalog

/// Тести переліку `HelpTopic` (вікно «Довідка», UC-17).
@MainActor
struct HelpTopicTests {

    @Test("6 розділів, як на екрані S-19, у кожного — назва, іконка, вступ і кроки")
    func everyTopicHasContent() {
        #expect(HelpTopic.allCases.count == 6)
        for topic in HelpTopic.allCases {
            #expect(topic.title.isEmpty == false)
            #expect(topic.systemImage.isEmpty == false)
            #expect(topic.intro.isEmpty == false)
            #expect(topic.steps.isEmpty == false)
        }
    }

    @Test("Розділ «Функції 1–6» описує всі 6 функцій, «Формат файлу» має приклад рядка")
    func functionsAndFormat() {
        #expect(HelpTopic.functions.steps.count == 6)
        #expect(HelpTopic.fileFormat.example.contains("ByteForge;Junior iOS Developer"))
        #expect(HelpTopic.gettingStarted.example.isEmpty)
    }
}
