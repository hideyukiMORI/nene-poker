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

    static let boxed = TerminalTraits(frame: .boxDrawing, colors: .trueColor)

    static func render(_ series: TableSeries, view: ViewMode, frame: FrameStyle = .boxDrawing) -> Grid {
        let options = DisplayOptions(
            theme: .standard, view: view, traits: TerminalTraits(frame: frame, colors: .trueColor))
        let state = ScreenState(series: series, options: options, seed: 1, countdown: Countdown(remaining: 2, total: 3))
        return TableRenderer.render(state, size: TableRenderer.minimumSize)
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
