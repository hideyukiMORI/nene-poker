import NeNePokerCore
import NeNePokerEngine

/// 1 つの配置（大の配置 112 × 28 か縮小版 80 × 24）の各部品の置き場所と描き方（画面仕様の B 案・ADR 0008・0012）。
///
/// 上端に題の帯、左に卓（フェルト）、右に罫線の枠の HUD、卓の下に COMMS の 2 行、下端にキーの帯。
/// 形は NeNe Igo の `ScreenLayout`（コミット 2a46f6e）にならった。
struct ScreenLayout: Sendable, Hashable {
    let feltColumn: Int
    let feltRow: Int
    let feltWidth: Int
    let feltHeight: Int
    let hudColumn: Int
    let hudWidth: Int
    let commsRow: Int
    let footerRow: Int
    let plan: FeltPlan

    /// 大の配置。
    static let large = ScreenLayout(
        feltColumn: 1, feltRow: 2, feltWidth: 76, feltHeight: 22, hudColumn: 79, hudWidth: 33, commsRow: 24,
        footerRow: 27, plan: .large)
    /// 縮小版（南の札も小さい札・HUD を詰める）。
    static let compact = ScreenLayout(
        feltColumn: 0, feltRow: 1, feltWidth: 50, feltHeight: 19, hudColumn: 51, hudWidth: 29, commsRow: 20,
        footerRow: 23, plan: .compactPlan)

    var isCompact: Bool {
        plan.compact
    }

    /// この配置がちょうど入る大きさ。
    var size: ScreenSize {
        ScreenSize(columns: hudColumn + hudWidth, rows: footerRow + 1)
    }

    func draw(_ state: ScreenState, into grid: inout Grid) {
        let glyphs = FrameGlyphs.of(state.options.traits.frame)
        let theme = state.options.theme
        band(row: 0, theme: theme, into: &grid)
        grid.write(
            ScreenChrome.header(state, glyphs: glyphs, compact: isCompact), column: 0, row: 0, background: theme.panel)
        FeltFrame(column: feltColumn, row: feltRow, width: feltWidth, height: feltHeight, plan: plan)
            .draw(state, glyphs: glyphs, into: &grid)
        for (offset, line) in hudLines(state, glyphs: glyphs).prefix(feltHeight).enumerated() {
            grid.write(line, column: hudColumn, row: feltRow + offset, background: theme.ground)
        }
        for (offset, line) in ScreenChrome.comms(state, glyphs: glyphs, compact: isCompact).enumerated() {
            grid.write(line, column: 0, row: commsRow + offset, background: theme.ground)
        }
        band(row: footerRow, theme: theme, into: &grid)
        grid.write(
            ScreenChrome.footer(state, glyphs: glyphs, compact: isCompact), column: 0, row: footerRow,
            background: theme.panel)
    }

    private func band(row: Int, theme: Theme, into grid: inout Grid) {
        grid.write(
            String(repeating: " ", count: grid.size.columns), column: 0, row: row,
            colors: CellColors(foreground: theme.text, background: theme.panel))
    }

    private func hudLines(_ state: ScreenState, glyphs: FrameGlyphs) -> [[Segment]] {
        let sections = HudSections(state: state, panel: Panel(width: hudWidth, glyphs: glyphs), compact: isCompact)
        let result = sections.result()
        let theme = state.options.theme
        let bottom = sections.panel.footer(frame: result.isEmpty ? theme.frame : theme.accentAlt)
        let top = sections.match() + sections.stacks()
        let logRows = feltHeight - top.count - result.count - 2
        return top + sections.log(rows: logRows) + result + [bottom]
    }
}
