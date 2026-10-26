import NeNePokerCore
import NeNePokerEngine

/// 上端の題・下端のキーのヘルプ（FR-15: 常に出す）とストリートと直前の行動。
///
/// 形は NeNe Igo の `ScreenChrome`（コミット 2a46f6e）にならった。
enum ScreenChrome {
    /// ` ▌NENE//POKER  │  TABLE 003  │  HAND 027  │  SEED 0x…  │  24BIT`
    static func header(_ state: ScreenState, glyphs: FrameGlyphs) -> [Segment] {
        let theme = state.options.theme
        let divider = Segment("  " + glyphs.vertical + "  ", theme.frame)
        return [
            Segment(" " + glyphs.marker + Wording.title, theme.accent), divider,
            Segment(Wording.headerTable(state.series.tableNumber), theme.text), divider,
            Segment(Wording.headerHand(state.series.hand.number), theme.text), divider,
            Segment(Wording.seed(state.seed), theme.text), divider,
            Segment(Wording.colors(state.options.traits.colors), theme.dim),
        ]
    }

    /// `[q] QUIT   [v] VIEW: YOU   │   FLOP   │   LAST MOYO bets 80`
    static func footer(_ state: ScreenState, glyphs: FrameGlyphs) -> [Segment] {
        let theme = state.options.theme
        let divider = Segment("   " + glyphs.vertical + "   ", theme.frame)
        var segments = [
            Segment(" " + Wording.quitKey, theme.accent), Segment(Wording.quitName, theme.dim),
            Segment(Wording.viewKey, theme.accent), Segment(Wording.viewName, theme.dim),
            Segment(Wording.viewName(state.options.view), theme.text), divider,
            Segment(Wording.street(state.series.hand.street), theme.text),
        ]
        if let last = lastAction(state.series) {
            segments += [divider, Segment(Wording.lastLabel, theme.dim), Segment(last, theme.text)]
        }
        return segments
    }

    /// 直前の行動（`MOYO bets 80`）。このハンドでまだ誰も行動していなければ nil。
    private static func lastAction(_ series: TableSeries) -> String? {
        for event in series.events.reversed() {
            switch event {
            case .acted(let seat, let action, let total):
                return series.lineup.persona(at: seat).shortName + " " + Wording.actionLog(action, total: total)
            case .dealt:
                continue
            }
        }
        return nil
    }
}
