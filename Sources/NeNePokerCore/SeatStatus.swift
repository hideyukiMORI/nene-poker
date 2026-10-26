/// ハンドの中の席の状態（ADR 0007）。
public enum SeatStatus: Sendable, Hashable {
    /// チップが無く、このハンドに配られていない（飛んだ席）。
    case out
    /// まだ行動できる。
    case active
    /// 降りた。
    case folded
    /// チップを全部出した。もう行動しないが、出した額までのポットを争う。
    case allIn
}
