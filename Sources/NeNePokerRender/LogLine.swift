import NeNePokerCore
import NeNePokerEngine

/// HUD の LOG の 1 行（ストリートの区切りか行動）を作る。
enum LogLine {
    /// このハンドの出来事を古い順に行にする。先頭はプリフロップの区切り。
    static func lines(_ series: TableSeries, theme: Theme) -> [[Segment]] {
        var lines = [[Segment(Wording.street(.preflop), theme.accent)]]
        for event in series.events {
            switch event {
            case .dealt(let street, _):
                let cards = series.hand.board.prefix(street.boardCount).map(Wording.card).joined(separator: " ")
                lines.append([
                    Segment(Wording.fitted(Wording.street(street), to: 6), theme.accent), Segment(cards, theme.text),
                ])
            case .acted(let seat, let action, let total):
                let name = series.lineup.persona(at: seat).shortName
                lines.append([
                    Segment(Wording.fitted(name, to: 7), theme.text),
                    Segment(Wording.actionLog(action, total: total), theme.dim),
                ])
            }
        }
        return lines
    }
}
