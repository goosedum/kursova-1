//
//  FlowLayout.swift
//  Розташування «як слова в тексті»: елементи йдуть зліва направо і переносяться на новий рядок.
//

import SwiftUI

/// Розкладає елементи зліва направо; той, що не вміщується в рядок, переходить на новий (Figma: auto layout «wrap»).
///
/// `Layout` — протокол SwiftUI для власного розташування. SwiftUI двічі звертається до нього:
/// `sizeThatFits` — «якого розміру буде контейнер?», `placeSubviews` — «постав кожен елемент на місце».
/// Обидва методи рахують позиції однаково, тому спільний розрахунок винесено в `arrange`.
struct FlowLayout: Layout {

    /// Відстань між елементами по горизонталі й між рядками.
    var spacing = AppSpacing.xs

    /// Розмір контейнера для доступної ширини `proposal.width`.
    /// `cache` протокол дозволяє використати для збереження розрахунків; нам він не потрібен, тому тип — `()`.
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        return arrange(subviews, maxWidth: maxWidth).size
    }

    /// Ставить кожен елемент у його позицію всередині `bounds`.
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let positions = arrange(subviews, maxWidth: bounds.width).positions
        for index in 0..<subviews.count {
            let point = CGPoint(x: bounds.minX + positions[index].x, y: bounds.minY + positions[index].y)
            subviews[index].place(at: point, proposal: .unspecified)
        }
    }

    /// Рахує позицію кожного елемента і загальний розмір.
    private func arrange(_ subviews: Subviews, maxWidth: CGFloat) -> (positions: [CGPoint], size: CGSize) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var width: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            // Елемент не вміщується в поточний рядок — переходимо на новий
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            width = max(width, x - spacing)
        }
        return (positions, CGSize(width: width, height: y + rowHeight))
    }
}
