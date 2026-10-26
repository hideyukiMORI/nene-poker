import NeNePokerCore
import NeNePokerEngine

/// HUD のパネルの各段（MATCH・STACKS・LOG・RESULT）の行を作る（FR-10）。勝率や推奨手は出さない（施主は言っていない）。
///
/// 段の形は NeNe Igo の `HudSections`（コミット 2a46f6e）にならった。
struct HudSections: Sendable {
    let state: ScreenState
    let panel: Panel
    /// 縮小版（ラベルを詰め、棒を短くする）。
    let compact: Bool

    private var theme: Theme {
        state.options.theme
    }

    private var series: TableSeries {
        state.series
    }

    /// MATCH: 卓・ハンド・ブラインドと段階・親。
    func match() -> [[Segment]] {
        let hand = series.hand
        let level = hand.level
        let gap = compact ? " " : "  "
        return [
            panel.header(Wording.match, title: theme.accent, frame: theme.frame, first: true),
            row([
                Segment("TABLE" + gap, theme.dim), Segment(Wording.tableNumber(series.tableNumber), theme.text),
                Segment(gap + "HAND" + gap, theme.dim), Segment(Wording.padded(hand.number, width: 3), theme.text),
            ]),
            row([
                Segment("BLINDS" + gap, theme.dim),
                Segment(Wording.chips(level.smallBlind) + "/" + Wording.chips(level.bigBlind), theme.text),
                Segment(gap + "LVL ", theme.dim), Segment(String(level.number), theme.text),
            ]),
            row([Segment("DEALER" + gap, theme.dim), Segment(series.lineup.persona(at: hand.button).name, theme.text)]),
        ]
    }

    /// STACKS: 席順（YOU・W・N・E）の棒と額。飛んだ席は `OUT`。
    func stacks() -> [[Segment]] {
        let total = series.table.totalChips
        let rows = Seat.allCases.map { seat -> [Segment] in
            let persona = series.lineup.persona(at: seat)
            let chips = stack(of: seat)
            let label = Segment(
                Wording.fitted(Wording.seatTag(seat), to: 4) + Wording.fitted(persona.shortName, to: 7), theme.text)
            guard chips > 0 || state.series.hand.status(of: seat) != .out else {
                return row([label, Segment(Wording.out, theme.dim)])
            }
            let bar = panel.bar(
                Fraction(value: chips, total: total), cells: compact ? 4 : 8, fill: theme.chipBar, frame: theme.frame)
            return row([label] + bar + [Segment(" " + Wording.rightAligned(Wording.chips(chips), to: 7), theme.text)])
        }
        return [panel.header(Wording.stacks, title: theme.accent, frame: theme.frame, first: false)] + rows
    }

    /// その席のいまのチップ（ハンドの途中は手元の分、卓の終わりは卓の値）。
    private func stack(of seat: Seat) -> Int {
        switch series.phase {
        case .tableOver:
            return series.table.stack(of: seat)
        case .playing, .handOver:
            if case .complete(let result) = series.hand.progress {
                return result.stacks[seat, default: 0]
            }
            return series.hand.stack(of: seat)
        }
    }

    /// LOG: このハンドの最近の `count` 行（最新が下。次に打つ席にカーソル）。
    func log(rows count: Int) -> [[Segment]] {
        var lines = LogLine.lines(series, theme: theme)
        if case .awaitingAction(let seat) = series.hand.progress, series.phase == .playing {
            let name = series.lineup.persona(at: seat).shortName
            lines.append([Segment(Wording.fitted(name, to: 7), theme.text), Segment(panel.glyphs.cursor, theme.accent)])
        }
        let recent = lines.suffix(count).map(row)
        let empty = Array(repeating: row([]), count: max(count - recent.count, 0))
        return [panel.header(Wording.log, title: theme.accent, frame: theme.frame, first: false)] + recent + empty
    }

    /// RESULT: ハンドの終わり（勝者・役・額）か卓の終わり（優勝と次の卓までの秒読み）。どちらでもなければ空。
    func result() -> [[Segment]] {
        let frame = theme.accentAlt
        var lines: [[Segment]]
        switch series.phase {
        case .playing:
            return []
        case .handOver:
            lines = handLines()
        case .tableOver(let champion):
            lines = tableLines(champion)
        }
        lines = Array((lines + Array(repeating: [], count: 3)).prefix(3))
        return [panel.header(Wording.result, title: theme.accentAlt, frame: frame, first: false)]
            + lines.map { panel.row($0, frame: frame) }
    }

    private func handLines() -> [[Segment]] {
        guard case .complete(let result) = series.hand.progress else {
            return []
        }
        var lines = result.awards.prefix(2).map { award -> [Segment] in
            let names = award.winners.map { series.lineup.persona(at: $0).shortName }.joined(separator: " / ")
            let label = award.winners.count > 1 ? Wording.split : Wording.winner
            return [
                Segment(label, theme.dim), Segment(names, theme.accentAlt),
                Segment("  +" + Wording.chips(award.amount), theme.text),
            ]
        }
        if let main = result.awards.first?.winners.first, let strength = result.shown[main] {
            lines += HandName.wrapped(HandName.of(strength), width: panel.width - 4).map { [Segment($0, theme.text)] }
        }
        return lines
    }

    private func tableLines(_ champion: Seat) -> [[Segment]] {
        let persona = series.lineup.persona(at: champion)
        var lines = [
            [Segment(Wording.champion, theme.dim), Segment(persona.name, theme.accentAlt)],
            [Segment(Wording.tablesWon, theme.dim), Segment(String(series.tally.wins(of: persona)), theme.text)],
        ]
        if let countdown = state.countdown {
            let bar = panel.bar(
                Fraction(value: countdown.remaining, total: countdown.total), cells: 10, fill: theme.accent,
                frame: theme.frame)
            lines.append(
                [Segment(Wording.nextTable, theme.dim)] + bar + [
                    Segment("  " + Wording.seconds(countdown.remaining), theme.accent)
                ])
        }
        return lines
    }

    func row(_ content: [Segment]) -> [Segment] {
        panel.row(content, frame: theme.frame)
    }
}
