//
//  VacancyFormView.swift
//  Форма вакансії (лист): додавання нової або редагування копії, помилки під полями, «Скасувати» / «Зберегти».
//

import SwiftUI

/// Форма вакансії (Figma: `Organism/VacancyForm`, екрани S-09, S-10, S-11; прецеденти UC-07, UC-08).
///
/// Форма змінює чернетку `draft`: нову вакансію (конструктор за замовчуванням) або **копію** вибраної (конструктор
/// копій) — тому «Скасувати» не змінює оригінал. Помилки показуються під полями одразу під час введення.
/// «Зберегти» завжди активна (D-31): якщо дані неправильні, каталог кидає виняток і з'являється алерт.
struct VacancyFormView: View {

    /// Стан вікна.
    let viewModel: CatalogViewModel
    /// Чернетка вакансії. `@Bindable` — щоб поля форми змінювали її властивості (`$draft.company`).
    @Bindable var draft: Vacancy

    /// Технології одним рядком через кому, як їх вводить користувач.
    @State private var technologiesText = ""
    /// Чи вже натискали «Зберегти» — після цього показуємо й помилки порожніх полів.
    @State private var hasTriedToSave = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            header

            Form {
                textField("Компанія", text: $draft.company, error: errorText(for: draft.company, check: draft.validateCompany))
                textField("Посада", text: $draft.title, error: errorText(for: draft.title, check: draft.validateTitle))
                LabeledContent("Спеціалізація") {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        TextField("Спеціалізація", text: $draft.specialization)
                            .labelsHidden()
                            .textInputSuggestions {
                                ForEach(viewModel.catalog.allSpecializations, id: \.self) { specialization in
                                    Text(specialization)
                                        .textInputCompletion(specialization)
                                }
                            }
                        fieldError(errorText(for: draft.specialization, check: draft.validateSpecialization))
                    }
                }

                Picker("Рівень досвіду", selection: $draft.experienceLevel) {
                    ForEach(ExperienceLevel.allCases) { level in
                        Text(level.title)
                            .tag(level)
                    }
                }
                .fixedSize()
                Picker("Формат роботи", selection: $draft.workFormat) {
                    ForEach(WorkFormat.allCases) { format in
                        Text(format.title)
                            .tag(format)
                    }
                }
                .fixedSize()

                TextField("Мін. зарплата, $", value: $draft.minSalary, format: .number)
                LabeledContent("Макс. зарплата, $") {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        TextField("Макс. зарплата, $", value: $draft.maxSalary, format: .number)
                            .labelsHidden()
                        // Помилка зарплати стосується обох полів, тому — під другим
                        fieldError(errorText(check: draft.validateSalary))
                    }
                }

                LabeledContent("Технології") {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        TextField("Swift, SwiftUI, Git", text: $technologiesText)
                            .labelsHidden()
                            .onChange(of: technologiesText) {
                                draft.technologies = technologiesText.components(separatedBy: ",")
                            }
                        fieldError(errorText(for: technologiesText, check: draft.validateTechnologies))
                    }
                }
            }
            .formStyle(.columns)

            Text("Технології — через кому. Рівень і формат вибираються зі списку, тому помилитися в них неможливо.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("Скасувати") {
                    viewModel.cancelEditing()
                }
                .keyboardShortcut(.cancelAction)
                Button("Зберегти") {
                    hasTriedToSave = true
                    viewModel.saveDraft()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(AppSpacing.xxl)
        .frame(width: 560)
        .onAppear {
            technologiesText = draft.technologies.joined(separator: ", ")
        }
        // Алерт помилки показуємо з листа: поки лист відкритий, вікно під ним алертів не показує
        .alert(viewModel.errorAlert?.alertTitle ?? "", isPresented: isErrorAlertPresented) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorAlert?.alertMessage ?? "")
        }
    }

    /// Заголовок листа і пояснення під ним.
    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            if viewModel.isEditingExisting {
                Text("Редагування вакансії")
                    .font(.headline)
                Text("Ви редагуєте копію вакансії (конструктор копій): «Скасувати» залишає оригінал без змін.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Нова вакансія")
                    .font(.headline)
                Text("Заповніть поля. Помилки з'являються під полями.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Текстове поле з підписом ліворуч і помилкою під ним.
    private func textField(_ label: String, text: Binding<String>, error: String?) -> some View {
        LabeledContent(label) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                TextField(label, text: text)
                    .labelsHidden()
                fieldError(error)
            }
        }
    }

    /// Рядок помилки під полем, якщо помилка є.
    @ViewBuilder
    private func fieldError(_ message: String?) -> some View {
        if let text = message {
            FieldErrorText(message: text)
        }
    }

    /// Помилка текстового поля. Поки поле порожнє і «Зберегти» ще не натискали, помилки не показуємо —
    /// щоб нова форма не була одразу вся червона.
    private func errorText(for value: String, check: () throws -> Void) -> String? {
        if value.trimmingCharacters(in: .whitespaces).isEmpty && hasTriedToSave == false {
            return nil
        }
        return errorText(check: check)
    }

    /// Текст помилки поля або `nil`, якщо поле правильне.
    ///
    /// `check` — метод перевірки цього поля (`draft.validateCompany` …): форма його викликає і, якщо він кинув
    /// виняток, показує текст цього винятку.
    private func errorText(check: () throws -> Void) -> String? {
        do {
            try check()
            return nil
        } catch let error as VacancyError {
            return error.errorDescription
        } catch {
            return nil
        }
    }

    /// Алерт показується, поки в `errorAlert` є помилка; «OK» закриває його, а форма лишається відкритою.
    private var isErrorAlertPresented: Binding<Bool> {
        return Binding(
            get: {
                return viewModel.errorAlert != nil
            },
            set: { isPresented in
                if isPresented == false {
                    viewModel.errorAlert = nil
                }
            }
        )
    }
}
