//
//  MergeSorter.swift
//  Сортування злиттям (merge sort) для масиву будь-якого типу — аналог шаблону класу в C++.
//

/// Сортує масив методом злиття.
///
/// `Element` — параметр типу, як `template <typename T>` у C++: той самий код сортує і вакансії, і числа, і рядки.
/// Як порівнювати елементи, задає замикання `isOrderedBefore`: воно повертає `true`, якщо перший елемент
/// має стояти раніше за другий.
/// ```swift
/// let sorter = MergeSorter<Vacancy>()
/// let sorted = sorter.sort(vacancies, by: { first, second in
///     return first.averageSalary > second.averageSalary
/// })
/// ```
/// Складність — O(n log n) за часом і O(n) додаткової пам'яті. Сортування стабільне: елементи з однаковим ключем
/// лишаються в тому порядку, у якому були (рішення D-11). Алгоритм — діаграми `docs/uml/4-activities/`.
class MergeSorter<Element> {

    /// Повертає новий відсортований масив; вихідний масив не змінюється.
    ///
    /// - Parameters:
    ///   - items: Масив, який треба відсортувати.
    ///   - isOrderedBefore: Повертає `true`, якщо перший елемент має стояти раніше за другий.
    /// - Returns: Ті самі елементи в новому порядку.
    func sort(_ items: [Element], by isOrderedBefore: (Element, Element) -> Bool) -> [Element] {
        // 1. Масив з 0 або 1 елемента вже відсортований — тут рекурсія зупиняється
        if items.count <= 1 {
            return items
        }

        // 2. Ділимо масив навпіл і кожну половину сортуємо цим самим методом (рекурсія)
        let middle = items.count / 2
        let left = sort(Array(items[0..<middle]), by: isOrderedBefore)
        let right = sort(Array(items[middle...]), by: isOrderedBefore)

        // 3. Зливаємо дві відсортовані половини в один відсортований масив
        return merge(left, right, by: isOrderedBefore)
    }

    /// Зливає два відсортовані масиви в один відсортований.
    private func merge(_ left: [Element], _ right: [Element],
                       by isOrderedBefore: (Element, Element) -> Bool) -> [Element] {
        var result: [Element] = []
        var i = 0
        var j = 0

        // Поки в обох половинах є елементи, переносимо в результат менший з двох перших
        while i < left.count && j < right.count {
            if isOrderedBefore(right[j], left[i]) {
                result.append(right[j])
                j += 1
            } else {
                // Лівий менший або рівний. При рівності беремо з лівої половини,
                // тому однакові елементи не міняються місцями (стабільність)
                result.append(left[i])
                i += 1
            }
        }

        // Одна з половин скінчилася — дописуємо залишок іншої (він уже відсортований)
        while i < left.count {
            result.append(left[i])
            i += 1
        }
        while j < right.count {
            result.append(right[j])
            j += 1
        }
        return result
    }
}
