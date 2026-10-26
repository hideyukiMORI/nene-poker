/// 卓をまたいで引き継ぐ値（何卓目か・通算の優勝・発言）。TableSeries の組み立ての中だけで使う。
struct SeriesRecord: Sendable, Hashable {
    let tableNumber: Int
    let tally: ChampionTally
    let banter: Banter
}
