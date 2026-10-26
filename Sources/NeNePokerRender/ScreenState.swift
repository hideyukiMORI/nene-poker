import NeNePokerEngine

/// 1 画面を描くのに要るすべての値（ARC-011: Render はこれを描くだけ）。
public struct ScreenState: Sendable {
    public let series: TableSeries
    public let options: DisplayOptions
    /// 卓の列のシード（画面に出す）。
    public let seed: UInt64
    /// 卓の終わりの、次の卓までの秒読み。それ以外は nil。
    public let countdown: Countdown?

    /// 組を作る。
    public init(series: TableSeries, options: DisplayOptions, seed: UInt64, countdown: Countdown?) {
        self.series = series
        self.options = options
        self.seed = seed
        self.countdown = countdown
    }
}
