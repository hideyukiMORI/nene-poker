@testable import NeNePokerCore
@testable import NeNePokerEngine

/// テストを速く回すための短い卓の決まり（初期のチップ 200・ブラインド 10 / 20 から 5 ハンドごとに上がる）。製品の決まりは `TableSetup.standard`。
enum Short {
    static let rules: TableRules = {
        guard let schedule = BlindSchedule.make(bigBlinds: [20, 40, 80, 160], handsPerLevel: 5),
            let rules = TableRules.make(startingStack: 200, schedule: schedule)
        else {
            preconditionFailure("テストの決まりは作れる")
        }
        return rules
    }()

    /// シードから始め、`tables` 卓が終わるまで進めた各歩の列。
    static func run(seed: UInt64, tables: Int, limit: Int = 200_000) -> [TableSeries] {
        var generator = SplitMix64(seed: seed)
        var series = TableSeries.first(rules: rules, using: &generator)
        var steps = [series]
        while series.tally.finishedTables < tables, steps.count < limit {
            series = series.advanced(using: &generator)
            steps.append(series)
        }
        return steps
    }
}
