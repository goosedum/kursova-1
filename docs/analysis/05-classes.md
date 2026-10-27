# Крок 1.5 — Ескіз класів

> Погоджено 26.10.2026 (рішення D-14 — варіант A, D-26 — `MergeSorter<Element>`). Основа діаграми класів (розділ 2.2
> звіту) і порядку програмування (етап 4). Діаграми класів (крок 3.2): [`docs/uml/2-classes/`](../uml/2-classes/) — огляд `1-overview` і три детальні.

## 1. Шари і залежності

```
Views (SwiftUI)  →  CatalogViewModel  →  Logic (каталог, операції, сортування)  →  Storage (файли)  →  Model (дані)
```
Кожен шар знає лише про шари праворуч. Model, Storage і Logic не залежать від SwiftUI — їх легко тестувати й пояснювати.
Кожен тип — в окремому файлі з такою самою назвою (вимога методички).

## 2. Класи та структури (без інтерфейсу)

### Model — дані

| Тип | Вид | Відповідальність | Головне |
|---|---|---|---|
| `Vacancy` | class | одна вакансія | 8 полів + `id`; `init()`, `init(company:…)`, `init(copyOf:)`, `deinit`; `averageSalary`, `salaryRange`, `hasTechnology(_:)`, `validate() throws` |
| `ExperienceLevel` | enum | рівень досвіду | 5 випадків; `title` (для UI), `order` (для порівняння) |
| `WorkFormat` | enum | формат роботи | 3 випадки; `title`, `systemImage` |
| `VacancyError` | enum : Error | усі виняткові ситуації | 13 випадків; `errorDescription` (що сталося), `recoverySuggestion` (що робити) |
| `VacancyGroup` | struct | група вакансій із заголовком | `title`, `subtitle` (напр. «макс − мін = $300»), `vacancies` — результат ф.1–6 (для списку — одна група без заголовка) |
| `SalaryRangeExtremes` | struct | результат ф.5 | `minRange`, `minRangeVacancies`, `maxRange`, `maxRangeVacancies` |

### Storage — файли

| Тип | Вид | Відповідальність | Головне |
|---|---|---|---|
| `VacancyFileReader` | class | читання файлу (аналог `ifstream`) | `init(url:) throws`; оператор `>>` заповнює вакансію і повертає `false` наприкінці файлу; `currentLineNumber` |
| `VacancyFileWriter` | class | запис файлу (аналог `ofstream`) | `init(url:)`; оператор `<<` додає вакансію; `save() throws` |

### Logic — каталог і функції

| Тип | Вид | Відповідальність | Головне |
|---|---|---|---|
| `VacancyCatalog` | class | зберігає вакансії, змінює їх тільки з перевіркою | `private(set) var vacancies`; `add`, `replace`, `remove`, `removeAll`; `load(from:)`, `save(to:)`; `allTechnologies`, `allSpecializations` |
| `MergeSorter<Element>` | class | сортування злиттям (вимога ф.4) | `sort(_:by:)` рекурсивно ділить навпіл, приватний `merge` зливає; стабільний |
| `CatalogOperation` + 6 підкласів, `OperationResult` | class / struct | функції варіанта | див. §3 |

### ViewModel

| Тип | Вид | Відповідальність |
|---|---|---|
| `CatalogViewModel` | class | стан вікна: каталог, вибрані вакансії, поточна функція і результат, форма, файл, незбережені зміни, помилка для алерта |

Інтерфейс (SwiftUI-структури: головне вікно, сайдбар, таблиця, форма, меню…) проєктуємо на етапі 2 у Figma.

## 3. Як оформити шість функцій (D-14 — обрано варіант A)

### ✅ Варіант A — базовий клас + 6 підкласів, логіка в підкласах (обрано)

```swift
/// Базовий клас для функцій аналізу каталогу.
class CatalogOperation {
    let title: String          // назва в сайдбарі й меню
    let systemImage: String    // іконка
    let helpText: String       // підказка

    init(title: String, systemImage: String, helpText: String) { … }

    /// Виконує функцію. Кожен підклас обов'язково перевизначає цей метод.
    func execute(on catalog: VacancyCatalog) throws -> OperationResult {
        fatalError("execute(on:) треба перевизначити в підкласі")
    }
}

/// Функція 2: пошук вакансій за технологією.
class SearchByTechnologyOperation: CatalogOperation {
    var technology = ""        // параметр функції

    override func execute(on catalog: VacancyCatalog) throws -> OperationResult {
        var found: [Vacancy] = []
        for vacancy in catalog.vacancies {
            if vacancy.hasTechnology(technology) {
                found.append(vacancy)
            }
        }
        return OperationResult(title: "Технологія: \(technology)", groups: [VacancyGroup(title: "Знайдено", vacancies: found)])
    }
}
```
У ViewModel — масив з 6 операцій; сайдбар і меню «Аналіз» будуються з нього, а виконання — один рядок
`result = try operation.execute(on: catalog)`, який сам викликає потрібну версію методу (**поліморфізм**).
- **Плюси:** природне успадкування й поліморфізм (головні теми захисту); кожна функція — окремий невеликий файл, який
  збігається з окремим алгоритмом у розділі 1 звіту; каталог лишається простим «сховищем».
- **Мінуси:** +8 файлів (база, 6 підкласів, `OperationResult`).

### Варіант B — 6 методів у `VacancyCatalog` + `switch` (відкинуто)

```swift
switch selectedFunction {
case .searchByTechnology:
    found = catalog.search(technology: technology)
case .filterByLevelAndFormat:
    found = catalog.filter(level: level, format: format)
// …
}
```
- **Плюси:** менше файлів, найпростіше.
- **Мінуси:** успадкування в проєкті немає взагалі (на захисті нема що показати), `switch` росте з кожною функцією,
  каталог стає великим.

### Варіант C — протокол + 6 структур (відкинуто)

```swift
protocol CatalogOperation {
    var title: String { get }
    func execute(on catalog: VacancyCatalog) throws -> OperationResult
}
struct SearchByTechnologyOperation: CatalogOperation { … }
```
- **Плюси:** «по-свіфтівськи»; протокол — аналог абстрактного класу з чистими віртуальними функціями C++.
- **Мінуси:** немає успадкування класів (а курс про C++-успадкування); структури копіюються, тож прив'язувати їх до полів
  форми трохи складніше.

## 4. Сортування злиттям (D-26 — обрано узагальнене)

- ✅ **`MergeSorter<Element>` (обрано)** — працює з будь-яким типом, а як саме порівнювати, передаємо замиканням
  `by: { $0.averageSalary > $1.averageSalary }`. Це аналог **шаблону** C++ (є в переліку питань), і ним же сортуємо групи у ф.6.
- **`VacancyMergeSorter`** (відкинуто) — тільки для `[Vacancy]`, ключ передається так само. Трохи простіше прочитати, але без прикладу generics.

## 5. Де в проєкті чотири принципи ООП (для захисту)

| Принцип | Де |
|---|---|
| **Інкапсуляція** | `VacancyCatalog.vacancies` — `private(set)`: змінюється лише через `add`/`replace`/`remove`, які перевіряють дані; у `VacancyFileReader` рядки файлу й лічильник приватні; `merge` у `MergeSorter` приватний |
| **Успадкування** | `CatalogOperation` → 6 підкласів (варіант A); `VacancyError` реалізує протокол `Error` |
| **Поліморфізм** | `operation.execute(on:)` для масиву різних операцій (перевизначення методів); перевизначені оператори `<<` і `>>`; `MergeSorter<Element>` |
| **Абстракція** | `CatalogOperation` — загальне поняття «функція аналізу»; `VacancyCatalog` приховує, як зберігаються дані; reader/writer приховують формат файлу |

## 6. Зв'язки між класами

- `VacancyCatalog` ◆— `Vacancy` (0..*) — **композиція**: каталог володіє вакансіями.
- `Vacancy` → `ExperienceLevel`, `Vacancy` → `WorkFormat` — **асоціація**.
- `VacancyCatalog` ⇢ `VacancyFileReader`, `VacancyFileWriter` — **залежність** (використовує під час `load`/`save`).
- `VacancyFileReader`, `VacancyFileWriter` ⇢ `Vacancy` — оператори `>>` і `<<`.
- `CatalogOperation` ◁— 6 підкласів — **узагальнення** (варіант A).
- `CatalogOperation` ⇢ `VacancyCatalog`, `OperationResult`; підкласи сортування ⇢ `MergeSorter`.
- `OperationResult` ◇— `VacancyGroup` — **агрегація**.
- `CatalogViewModel` ◇— `VacancyCatalog`, `CatalogOperation` (6) — **агрегація**.
