@testable import NeNePokerCore
@testable import NeNePokerEngine
@testable import NeNePokerRender

/// 画面のテストの材料（短い卓を乱数で進めた列と、それを描いた格子）。
enum Steps {
    static let rules: TableRules = {
        guard let schedule = BlindSchedule.make(bigBlinds: [20, 40, 80, 160], handsPerLevel: 5),
            let rules = TableRules.make(startingStack: 300, schedule: schedule)
        else {
            preconditionFailure("テストの決まりは作れる")
        }
        return rules
    }()

    /// シードから、3 卓が終わるまでの各歩。
    static let all: [TableSeries] = {
        var generator = SplitMix64(seed: 9)
        var series = TableSeries.first(rules: rules, using: &generator)
        var steps = [series]
        while series.tally.finishedTables < 3 {
            series = series.advanced(using: &generator)
            steps.append(series)
        }
        return steps
    }()

    /// 条件に合う歩。`all` に無ければ、ほかのシードの 1 卓ずつを順に探す（AI の打ち方では珍しい場面のため）。
    static func find(_ matches: (TableSeries) -> Bool) -> TableSeries? {
        if let found = all.first(where: matches) {
            return found
        }
        for seed in 100..<160 {
            var generator = SplitMix64(seed: UInt64(seed))
            var series = TableSeries.first(rules: rules, using: &generator)
            while series.tally.finishedTables < 1 {
                if matches(series) {
                    return series
                }
                series = series.advanced(using: &generator)
            }
        }
        return nil
    }

    static let boxed = TerminalTraits(frame: .boxDrawing, colors: .trueColor)

    static func render(
        _ series: TableSeries, view: ViewMode, frame: FrameStyle = .boxDrawing,
        layout: Layout = Layout(theme: .standard)
    ) -> Grid {
        let traits = TerminalTraits(frame: frame, colors: .trueColor)
        let options = DisplayOptions(theme: layout.theme, view: view, traits: traits)
        let state = ScreenState(series: series, options: options, seed: 1, countdown: Countdown(remaining: 2, total: 3))
        return TableRenderer.render(state, size: layout.compact ? TableRenderer.minimumSize : TableRenderer.largeSize)
    }

    static func cells(_ grid: Grid) -> [Cell] {
        (0..<grid.size.rows).flatMap { row in (0..<grid.size.columns).map { grid[$0, row] } }
    }

    static func text(_ grid: Grid) -> String {
        (0..<grid.size.rows).map { row in String((0..<grid.size.columns).map { grid[$0, row].character }) }
            .joined(separator: "\n")
    }

    /// 間引いた歩（描くテストを速くするため）。
    static var sampled: [TableSeries] {
        all.enumerated().filter { $0.offset % 7 == 0 }.map(\.element)
    }
}
