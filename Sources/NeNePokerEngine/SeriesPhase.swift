import NeNePokerCore

/// 卓の列の段階（ADR 0008）。
public enum SeriesPhase: Sendable, Hashable {
    /// ハンドの途中。
    case playing
    /// ハンドが終わり、結果を見せている。
    case handOver
    /// 卓が終わり、優勝した席の結果と次の卓までの秒読みを見せている。
    case tableOver(champion: Seat)
}
