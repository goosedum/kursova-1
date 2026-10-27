//
//  HelpView.swift
//  Вікно «Довідка»: розділи ліворуч, текст вибраного розділу праворуч.
//

import SwiftUI

/// Вікно довідки (Figma: `Organism/HelpWindow`, екран S-19; відкривається ⌘? з меню «Довідка»).
struct HelpView: View {

    /// Вибраний розділ (за замовчуванням — «Початок роботи»).
    @State private var selectedTopic: HelpTopic? = .gettingStarted

    var body: some View {
        NavigationSplitView {
            List(HelpTopic.allCases, selection: $selectedTopic) { topic in
                Label(topic.title, systemImage: topic.systemImage)
                    .tag(topic)
            }
            .navigationSplitViewColumnWidth(200)
        } detail: {
            if let topic = selectedTopic {
                page(for: topic)
            } else {
                ContentUnavailableView("Виберіть розділ", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle("Довідка")
    }

    /// Сторінка розділу: заголовок, вступ, кроки, приклад, порада.
    private func page(for topic: HelpTopic) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Довідка")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(topic.title)
                        .font(.title.weight(.bold))
                }
                Text(topic.intro)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    ForEach(0..<topic.steps.count, id: \.self) { index in
                        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.s) {
                            Text("\(index + 1)")
                                .foregroundStyle(Color.accentColor)
                                .monospacedDigit()
                            Text(topic.steps[index])
                        }
                    }
                }

                if topic.example.isEmpty == false {
                    Text(topic.example)
                        .font(.system(.callout, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(AppSpacing.m)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColor.chipBackground, in: RoundedRectangle(cornerRadius: AppRadius.s))
                }

                if topic.tip.isEmpty == false {
                    Label(topic.tip, systemImage: "info.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(AppSpacing.m)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColor.chipBackground, in: RoundedRectangle(cornerRadius: AppRadius.m))
                }
            }
            .padding(AppSpacing.xxl)
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview("HelpView") {
    HelpView()
        .frame(width: 760, height: 520)
}
