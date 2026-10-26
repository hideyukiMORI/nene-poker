import NeNePokerCore
import NeNePokerEngine

/// 上端の題・卓の下の COMMS・下端のキーのヘルプ（FR-15: 常に出す）とストリートと直前の行動。
///
/// 形は NeNe Igo の `ScreenChrome`（コミット 2a46f6e）にならった。
enum ScreenChrome {
    /// ` ▌NENE//POKER  │  TABLE 003  │  HAND 027  │  SEED 0x…  │  24BIT`
    static func header(_ state: ScreenState, glyphs: FrameGlyphs, compact: Bool) -> [Segment] {
        let theme = state.options.theme
        let divider = Segment(compact ? " " + glyphs.vertical + " " : "  " + glyphs.vertical + "  ", theme.frame)
        return [
            Segment(" " + glyphs.marker + Wording.title, theme.accent), divider,
            Segment(Wording.headerTable(state.series.tableNumber), theme.text), divider,
            Segment(Wording.headerHand(state.series.hand.number), theme.text), divider,
            Segment(Wording.seed(state.seed), theme.text), divider,
            Segment(Wording.colors(state.options.traits.colors), theme.dim),
        ]
    }

    /// `[q] QUIT   [t] THEME: NEON   [v] VIEW: YOU   │   FLOP   │   LAST ODDS bets 80`（縮小版は詰める）
    static func footer(_ state: ScreenState, glyphs: FrameGlyphs, compact: Bool) -> [Segment] {
        let theme = state.options.theme
        let divider = Segment(compact ? " " + glyphs.vertical + " " : "   " + glyphs.vertical + "   ", theme.frame)
        var segments = [
            Segment(" " + Wording.quitKey, theme.accent), Segment(compact ? " " : Wording.quitName, theme.dim),
            Segment(Wording.themeKey, theme.accent), Segment(compact ? " " : Wording.themeName, theme.dim),
            Segment(theme.name + (compact ? " " : "   "), theme.text),
            Segment(Wording.viewKey, theme.accent), Segment(compact ? " " : Wording.viewName, theme.dim),
            Segment(Wording.viewName(state.options.view), theme.text), divider,
            Segment(Wording.street(state.series.hand.street), theme.text),
        ]
        if let last = lastAction(state.series) {
            segments += [divider, Segment(compact ? "" : Wording.lastLabel, theme.dim), Segment(last, theme.text)]
        }
        return segments
    }

    /// COMMS の 2 行（古い方は控えめな色、新しい方は話し手の名前を強調の色で）。
    static func comms(_ state: ScreenState, glyphs: FrameGlyphs, compact: Bool) -> [[Segment]] {
        let theme = state.options.theme
        let lines = state.series.banter.lines
        return lines.enumerated().map { index, remark in
            let tag = Wording.fitted(Wording.seatTag(remark.seat), to: 4)
            let name = compact ? remark.persona.name + " " : Wording.fitted(remark.persona.name, to: 11)
            let lead = compact ? glyphs.marker + tag : " " + glyphs.marker + " " + tag
            let face = remark.face + (compact ? " " : "  ")
            guard index == lines.count - 1 else {
                return [Segment(lead + name + face + remark.text, theme.dim)]
            }
            return [
                Segment(lead + name, theme.accent), Segment(face, theme.accentAlt), Segment(remark.text, theme.text),
            ]
        }
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
