import NeNePokerCore

/// 札を札の地の色で塗った偶数桁のブロックに描く（FR-07b・ADR 0008）。文字はランクとスートの ASCII だけ。
struct CardPainter: Sendable {
    let theme: Theme

    /// 小さい札（4 桁 × 1 行）: ` Ah `・裏 ` ## `・空の枠 ` -- `。
    func small(_ card: Card?, _ show: CardShow, at point: GridPoint, into grid: inout Grid) {
        let colors = self.colors(card, show)
        let text = " " + label(card, show) + " "
        grid.write(text, column: point.column, row: point.row, colors: colors)
    }

    /// 大きい札（6 桁 × 4 行）: 2 行目の左にランク、3 行目の右にスート。裏は中央に `##` を 2 行。
    func large(_ card: Card?, _ show: CardShow, at point: GridPoint, into grid: inout Grid) {
        let colors = self.colors(card, show)
        let lines: [String]
        if let card, show == .faceUp || show == .foldedFaceUp {
            let rank = String(CardNotation.symbol(of: card.rank))
            let suit = String(CardNotation.symbol(of: card.suit))
            lines = ["      ", " " + rank + "    ", "    " + suit + " ", "      "]
        } else if show == .faceDown {
            lines = ["      ", "  ##  ", "  ##  ", "      "]
        } else {
            lines = ["      ", "  --  ", "      ", "      "]
        }
        for (offset, line) in lines.enumerated() {
            grid.write(line, column: point.column, row: point.row + offset, colors: colors)
        }
    }

    /// 場札の 1 枠（まだ開いていなければ `--` の空の枠）。
    func board(_ card: Card?, at point: GridPoint, into grid: inout Grid) {
        small(card, card == nil ? .empty : .faceUp, at: point, into: &grid)
    }

    private func label(_ card: Card?, _ show: CardShow) -> String {
        switch show {
        case .faceUp, .foldedFaceUp:
            return card.map(Wording.card) ?? Wording.emptyCard
        case .faceDown:
            return Wording.cardBack
        case .none, .empty:
            return Wording.emptyCard
        }
    }

    private func colors(_ card: Card?, _ show: CardShow) -> CellColors {
        switch show {
        case .faceUp:
            guard let card else {
                return CellColors(foreground: theme.feltText, background: theme.felt)
            }
            return CellColors(foreground: theme.color(of: card.suit), background: theme.cardFace)
        case .foldedFaceUp:
            return CellColors(foreground: theme.foldedText, background: theme.foldedFace)
        case .faceDown:
            return CellColors(foreground: theme.cardBackText, background: theme.cardBack)
        case .none, .empty:
            return CellColors(foreground: theme.feltText, background: theme.felt)
        }
    }
}
