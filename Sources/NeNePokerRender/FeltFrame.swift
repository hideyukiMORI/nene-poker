import NeNePokerCore
import NeNePokerEngine

/// 卓（フェルト）の枠と、その中の 4 席・場札・ポット（画面仕様の Layout・ADR 0008）。
///
/// 席は固定で、メインの子が南（手前・大きい札）、ほか 3 人が西・北・東（小さい札）。場札とポットは中央。
struct FeltFrame: Sendable {
    let column: Int
    let row: Int
    let width: Int
    let height: Int

    /// 枠の中の左上（中身の原点）。
    private var inner: GridPoint {
        GridPoint(column: column + 1, row: row + 1)
    }

    func draw(_ state: ScreenState, glyphs: FrameGlyphs, into grid: inout Grid) {
        let theme = state.options.theme
        border(theme: theme, glyphs: glyphs, into: &grid)
        for offset in 1..<(height - 1) {
            grid.paint(column: column + 1, row: row + offset, width: width - 2, color: theme.felt)
        }
        let seats = SeatPanel(state: state, painter: CardPainter(theme: theme), glyphs: glyphs)
        let origin = inner
        seats.small(.north, column: origin.column + 26, row: origin.row, into: &grid)
        seats.small(.west, column: origin.column + 2, row: origin.row + 7, into: &grid)
        seats.small(.east, column: origin.column + 50, row: origin.row + 7, into: &grid)
        seats.main(column: origin.column + 18, row: origin.row + 12, into: &grid)
        center(state, theme: theme, into: &grid)
    }

    private func border(theme: Theme, glyphs: FrameGlyphs, into grid: inout Grid) {
        let colors = CellColors(foreground: theme.frame, background: theme.ground)
        let line = String(repeating: glyphs.horizontal, count: width - 2)
        grid.write(glyphs.topLeft + line + glyphs.topRight, column: column, row: row, colors: colors)
        grid.write(glyphs.bottomLeft + line + glyphs.bottomRight, column: column, row: row + height - 1, colors: colors)
        for offset in 1..<(height - 1) {
            grid.write(glyphs.vertical, column: column, row: row + offset, colors: colors)
            grid.write(glyphs.vertical, column: column + width - 1, row: row + offset, colors: colors)
        }
    }

    /// 場札 5 枠とポットの行（`POT 360 + SIDE 120 + 40`）。
    private func center(_ state: ScreenState, theme: Theme, into grid: inout Grid) {
        let hand = state.series.hand
        let painter = CardPainter(theme: theme)
        let origin = inner
        let boardColumn = origin.column + 25
        for slot in 0..<5 {
            let card = slot < hand.board.count ? hand.board[slot] : nil
            painter.board(card, at: GridPoint(column: boardColumn + slot * 5, row: origin.row + 8), into: &grid)
        }
        let layers = hand.potLayers.map(\.amount)
        let sides = layers.dropFirst().enumerated().map { index, amount in
            (index == 0 ? Wording.sideLabel : " + ") + Wording.chips(amount)
        }
        let text = Wording.potLabel + Wording.chips(layers.first ?? 0) + sides.joined()
        let start = origin.column + (width - 2 - text.count) / 2
        grid.write(
            text, column: start, row: origin.row + 10,
            colors: CellColors(foreground: theme.feltText, background: theme.felt))
    }
}
