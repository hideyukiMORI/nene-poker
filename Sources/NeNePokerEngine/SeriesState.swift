import NeNePokerCore

/// 卓の列の値の組（TableSeries の組み立ての中だけで使う）。
struct SeriesState: Sendable, Hashable {
    let table: Table
    let hand: Hand
    let phase: SeriesPhase
    let tableNumber: Int
    let lineup: Lineup
    let tally: ChampionTally
    let events: [TableEvent]
    let banter: Banter
}
