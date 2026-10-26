import NeNePokerCore
import NeNePokerEngine

/// 1 つの席の名前・顔・印・チップ・直前の行動・札を描く（画面仕様の Seat・ADR 0008）。
struct SeatPanel: Sendable {
    let state: ScreenState
    let painter: CardPainter
    let glyphs: FrameGlyphs

    private var theme: Theme {
        state.options.theme
    }

    private var hand: Hand {
        state.series.hand
    }

    /// 西・北・東の席: 名前の行・小さい札 2 枚と位置の印・チップと直前の行動。
    func small(_ seat: Seat, column: Int, row: Int, into grid: inout Grid) {
        grid.write(nameLine(seat), column: column, row: row, background: theme.felt)
        let show = CardVisibility.show(seat, in: hand, view: state.options.view)
        if show != .none {
            let cards = hand.holeCards(of: seat)
            for (index, card) in cards.enumerated() {
                painter.small(card, show, at: GridPoint(column: column + 2 + index * 5, row: row + 1), into: &grid)
            }
        }
        grid.write(position(seat), column: column + 12, row: row + 1, background: theme.felt)
        grid.write(stackLine(seat), column: column + 2, row: row + 2, background: theme.felt)
    }

    /// 南の席（メインの子）: 名前の行・チップと位置と直前の行動・大きい札 2 枚・いまの役の名前。
    func main(column: Int, row: Int, into grid: inout Grid) {
        let seat = Seat.south
        grid.write(nameLine(seat), column: column, row: row, background: theme.felt)
        grid.write(stackLine(seat) + position(seat), column: column + 2, row: row + 1, background: theme.felt)
        let show = CardVisibility.show(seat, in: hand, view: state.options.view)
        guard show != .none else {
            return
        }
        for (index, card) in hand.holeCards(of: seat).enumerated() {
            painter.large(card, show, at: GridPoint(column: column + 2 + index * 8, row: row + 2), into: &grid)
        }
        if let name = handName(of: seat) {
            let colors = CellColors(foreground: theme.feltText, background: theme.felt)
            grid.write(name, column: column + 19, row: row + 3, colors: colors)
        }
    }

    /// `> BLUFF.EXE >:] (D)`（手番なら `>`）。
    private func nameLine(_ seat: Seat) -> [Segment] {
        let persona = state.series.lineup.persona(at: seat)
        let turn: Bool
        if case .awaitingAction(let mover) = hand.progress, state.series.phase == .playing {
            turn = mover == seat
        } else {
            turn = false
        }
        let marker = Segment(turn ? glyphs.turn + " " : "  ", theme.turnMarker)
        let name = Segment(persona.name + " " + persona.face, turn ? theme.turnMarker : theme.feltText)
        let button = Segment(hand.button == seat ? " " + Wording.dealer : "", theme.feltText)
        return [marker, name, button]
    }

    /// `SB` / `BB`（ヘッズアップの親は `SB`）。
    private func position(_ seat: Seat) -> [Segment] {
        var tags: [String] = []
        if hand.smallBlindSeat == seat {
            tags.append(Wording.smallBlind)
        }
        if hand.bigBlindSeat == seat {
            tags.append(Wording.bigBlind)
        }
        return [Segment(tags.isEmpty ? "" : "  " + tags.joined(separator: " "), theme.feltText)]
    }

    /// `1,240  CALL 80`（飛んだ席は `OUT`）。
    private func stackLine(_ seat: Seat) -> [Segment] {
        guard hand.status(of: seat) != .out else {
            return [Segment(Wording.out, theme.feltText)]
        }
        let word = SeatWord.of(seat, events: state.series.events).map { "  " + $0 } ?? ""
        return [Segment(Wording.chips(stack(of: seat)), theme.feltText), Segment(word, theme.feltText)]
    }

    /// 席のチップ。ハンドが終わっていれば分配の後の値（HUD の STACKS と同じ・ADR 0010）。
    private func stack(of seat: Seat) -> Int {
        if case .complete(let result) = hand.progress {
            return result.stacks[seat, default: 0]
        }
        return hand.stack(of: seat)
    }

    /// 場札が 3 枚以上開いていれば、手札と場札の最良の 5 枚の役の名前。
    private func handName(of seat: Seat) -> String? {
        let cards = hand.holeCards(of: seat) + hand.board
        guard hand.board.count >= 3, cards.count >= 5 else {
            return nil
        }
        return HandName.of(HandEvaluator.strength(of: CardSet.of(cards)))
    }
}
